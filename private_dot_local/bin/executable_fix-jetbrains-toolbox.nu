#!/usr/bin/env nu

# Diagnose the SysV semaphore that blocks JetBrains Toolbox from starting.
#
# Toolbox derives its start lock key with ftok(), so the key only encodes the device and the low 16
# bits of an inode. A crashed Toolbox (or a second user on the same box whose home hashes to the same
# key) leaves a 0600 semaphore behind and every later start fails with EACCES.
#
#   fix-jetbrains-toolbox.nu                       # newest secondary log
#   fix-jetbrains-toolbox.nu path/to/toolbox.log   # a specific log
#   fix-jetbrains-toolbox.nu --remove              # run ipcrm when it is safe

const DEFAULT_LOG_DIR = "~/.local/share/JetBrains/Toolbox/logs/secondary"

# errno values Toolbox reports from semget().
const ERRNO_MEANING = {
	"2": "ENOENT: no such semaphore. Not a stale-lock problem."
	"13": "EACCES: the semaphore exists but this user cannot open it (created 0600 by another uid)."
	"17": "EEXIST: the semaphore already exists and was requested exclusively."
	"28": "ENOSPC: the system-wide semaphore limit is exhausted (see /proc/sys/kernel/sem)."
}

# Run an external command, failing loudly instead of returning a plausible-looking empty result.
def run-checked [
	name: string,		# Command name, for the error message
	--allow-empty,		# Treat exit code 1 (no matches) as success with empty stdout
]: record -> any {
	let result = $in
	if $result.exit_code == 0 {
		return $result.stdout
	}
	# Exit 1 means "no matches" only when nothing was written to stderr; a usage error also exits 1.
	if $allow_empty and $result.exit_code == 1 and ($result.stderr | str trim | is-empty) {
		return ""
	}
	error make {
		msg: $"($name) failed with exit code ($result.exit_code): ($result.stderr | str trim)"
	}
}

def require-command [name: string] {
	if (which $name | is-empty) {
		error make { msg: $"'($name)' not found in PATH. Install it and try again." }
	}
}

# Newest Toolbox log under the given directory. The `.latest.log` files are hard links to the
# numbered ones, so they are skipped to avoid reporting the same file twice.
def newest-log [log_dir: string] {
	let dir = $log_dir | path expand
	if not ($dir | path exists) {
		error make { msg: $"Toolbox log directory not found: ($dir)" }
	}
	# `into glob` is required: a string held in a variable is passed to `ls` literally.
	let logs = ls ($dir | path join "*.log" | into glob)
		| where name !~ '\.latest\.log$'
		| sort-by modified --reverse
	if ($logs | is-empty) {
		error make { msg: $"No Toolbox logs found in ($dir)" }
	}
	$logs | first | get name
}

# Pull the start-lock facts out of one Toolbox log.
def parse-log [log: string] {
	let text = open --raw $log | decode utf-8
	let keys = $text | parse --regex 'Semaphore \| ipc_key=(?<key>-?\d+)' | get key | uniq
	if ($keys | is-empty) {
		error make { msg: $"No 'ipc_key=' line in ($log). Toolbox never reached the start lock." }
	}
	let key = $keys | last | into int
	let errnos = $text | parse --regex 'Unexpected error code after a syscall: (?<errno>\d+)' | get errno
	{
		file: $log
		version: ($text | parse --regex '(?m)^(?<version>[\d.]+)\s' | get version | first | default "unknown")
		pid: ($text | parse --regex 'ToolboxEntry \| pid: (?<pid>\d+)' | get pid | first | default "unknown")
		instance: ($text | parse --regex 'instance type: (?<instance>\w+)' | get instance | last | default "unknown")
		key_signed: $key
		key_unsigned: (if $key < 0 { $key + 4294967296 } else { $key })
		errno: (if ($errnos | is-empty) { null } else { $errnos | last })
	}
}

# `ipcs` semaphore table, keys resolved to integers so they can be compared with the log key.
def semaphore-table [] {
	let arrays = ^ipcs --semaphores | complete | run-checked "ipcs --semaphores"
		| lines
		| where ($it | str starts-with "0x")
		| each {|row|
			let cols = $row | split row --regex '\s+'
			{
				key_hex: $cols.0
				key: ($cols.0 | str replace "0x" "" | into int --radix 16)
				semid: ($cols.1 | into int)
				owner: $cols.2
				perms: $cols.3
				nsems: ($cols.4 | into int)
			}
		}
	let times = ^ipcs --semaphores --time | complete | run-checked "ipcs --semaphores --time"
		| lines
		| skip 3
		| each {|row| $row | split row --regex '\s+' }
		| where { ($in | length) > 2 and (($in | first) =~ '^\d+$') }
		# Columns: semid, owner, last-op (5 tokens), last-changed (5 tokens).
		| each {|cols| { semid: ($cols.0 | into int), last_changed: ($cols | skip 7 | str join " ") } }
	$arrays | each {|row|
		let time_row = $times | where semid == $row.semid
		let last_changed = if ($time_row | is-empty) { "unknown" } else { $time_row | first | get last_changed }
		$row | merge { last_changed: $last_changed }
	}
}

# Processes of the given user that hold a Toolbox start lock.
# The pattern is the 15-character comm name; pgrep refuses longer patterns without --full, and
# --full would also match this script's own command line.
def toolbox-processes [user: string] {
	^pgrep --uid $user --exact jetbrains-toolb --list-name | complete | run-checked "pgrep" --allow-empty
		| lines
		| where ($it | str trim) != ""
}

def main [
	log?: string				# Toolbox log to analyze. Default: newest log in --log-dir
	--log-dir: string = $DEFAULT_LOG_DIR	# Directory scanned when no log is given
	--remove				# Remove the semaphore instead of only printing the command
] {
	require-command "ipcs"
	let user = ^id --user --name | complete | run-checked "id" | str trim
	let log_file = if ($log | is-empty) { newest-log $log_dir } else { $log | path expand }
	if not ($log_file | path exists) {
		error make { msg: $"Log file not found: ($log_file)" }
	}

	let parsed = parse-log $log_file
	print $"Log:          ($parsed.file)"
	print $"Toolbox:      ($parsed.version), pid ($parsed.pid), instance type ($parsed.instance)"
	print $"ipc_key:      ($parsed.key_signed) \(($parsed.key_unsigned | format number | get lowerhex)\)"
	if ($parsed.errno | is-not-empty) {
		let meaning = $ERRNO_MEANING | get --optional $parsed.errno | default "unknown errno"
		print $"semget errno: ($parsed.errno) - ($meaning)"
	} else {
		print "semget errno: none logged. This start did not fail on the semaphore."
	}
	print ""

	let matches = semaphore-table | where key == $parsed.key_unsigned
	if ($matches | is-empty) {
		print $"No semaphore with key ($parsed.key_unsigned | format number | get lowerhex) exists right now."
		print "Nothing to remove; the start failure has another cause. Check the log for the full stack trace."
		return
	}
	print "Matching semaphore:"
	print ($matches | select key_hex semid owner perms nsems last_changed)
	print ""

	let sem = $matches | first
	let running = toolbox-processes $user
	let ipcrm_cmd = $"ipcrm --semaphore-id ($sem.semid)"

	if $sem.owner != $user {
		print $"Owner is '($sem.owner)', not '($user)'. ftok\(\) mapped both homes to the same key, so this is a"
		print "collision, not your stale lock. ipcrm as this user will fail with EPERM."
		print $"Fix: have '($sem.owner)' quit Toolbox and run '($ipcrm_cmd)', or run it as root, and only while"
		print $"'($sem.owner)' has no Toolbox running - removing a live lock breaks their session."
		exit 1
	}

	if ($running | is-not-empty) {
		print "A Toolbox process of yours is still running and may own this semaphore:"
		$running | each {|proc| print $"  ($proc)" }
		print "Quit Toolbox first, then re-run. Removing a live start lock lets two instances race."
		exit 1
	}

	if not $remove {
		print $"Stale lock from a crashed Toolbox. Remove it with:\n  ($ipcrm_cmd)"
		print "Re-run with --remove to have this script do it."
		return
	}

	require-command "ipcrm"
	let result = ^ipcrm --semaphore-id $sem.semid | complete
	if $result.exit_code != 0 {
		error make { msg: $"($ipcrm_cmd) failed with exit code ($result.exit_code): ($result.stderr | str trim)" }
	}
	print $"Removed semaphore semid ($sem.semid) \(key ($sem.key_hex)\). Start Toolbox again."
}

