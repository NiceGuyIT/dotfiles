#!/usr/bin/env nu

def highlight [value: int]: nothing -> string {
	if $value == 0 { $"($value)" } else { $"(ansi yellow_bold)($value)(ansi reset)" }
}

# Repository paths under the cwd, excluding submodules (the parent repo manages those) and `.claude` directories
# (agent worktrees live there).
# --show-superproject-working-tree prints the parent worktree in a submodule, nothing elsewhere.
def repo-paths []: nothing -> list<string> {
	glob **/.git --depth 10 --exclude [**/.claude/**]
	| each {|it| $it | path dirname}
	| where {|it|
		let superproject = (^git -C $it rev-parse --show-superproject-working-tree | complete)
		$superproject.exit_code != 0 or ($superproject.stdout | str trim | is-empty)
	}
}

export def "repos status" [--list, --remote] {
	repo-paths
	| each {|it|
		let relative = ($it | path relative-to (pwd))
		cd $it

		let branch = (git branch --show-current)
		let origin = (git remote get-url origin | complete)
		let remote_url = if ($origin.exit_code == 0) { $origin.stdout | str trim | str replace --regex '^\w+://' '' | str replace --regex '^[^@]+@' '' } else { "" }
		let ahead_behind = (git rev-list --left-right --count $"origin/($branch)...HEAD" | complete)
		let ahead = if ($ahead_behind.exit_code == 0) {
			$ahead_behind.stdout | split row "\t" | get 1 | str trim | into int
		} else { 0 }
		let behind = if ($ahead_behind.exit_code == 0) {
			$ahead_behind.stdout | split row "\t" | get 0 | str trim | into int
		} else { 0 }

		let porcelain = (git status --porcelain | parse --regex '(?P<index>.)(?P<worktree>.) (?P<file>.+)')
		let staged = ($porcelain | where {|row| $row.index != " " and $row.index != "?"} | get file)
		let unstaged = ($porcelain | where {|row| $row.worktree != " " and $row.worktree != "?"} | get file)
		let untracked = ($porcelain | where {|row| $row.index == "?" and $row.worktree == "?"} | get file)

		if $list {
			{
				repo: $relative
				branch: $branch
				staged: $staged
				unstaged: $unstaged
				untracked: $untracked
			}
		} else {
			let row = {
				repo: $relative
				branch: (if $branch == "main" { $branch } else { $"(ansi yellow_bold)($branch)(ansi reset)" })
				ahead: (highlight $ahead)
				behind: (highlight $behind)
				staged: (highlight ($staged | length))
				unstaged: (highlight ($unstaged | length))
				untracked: (highlight ($untracked | length))
			}
			if $remote {
				$row | insert remote $remote_url
			} else {
				$row
			}
		}
	}
}

# Reset the `common` submodule to the commit the parent records; no-op when the repo has none.
def reset-common-submodule []: nothing -> record<ok: bool, error: string> {
	let declared = (^git config --file .gitmodules --get submodule.common.path | complete)
	if $declared.exit_code != 0 { return { ok: true, error: "" } }

	let result = (^git submodule update --init common | complete)
	{ ok: ($result.exit_code == 0), error: ($result.stderr | str trim) }
}

# Pull every repo; --untracked also pulls repos whose only changes are untracked files.
# A failing pull (e.g. an incoming file would overwrite an untracked one) leaves the repo as plain `git pull` would.
export def "repos pull" [--untracked] {
	repo-paths
	| each {|it|
		let relative = ($it | path relative-to (pwd))
		cd $it

		# Reset first: a drifted submodule makes the parent look dirty and would skip the pull.
		let before = (reset-common-submodule)
		if not $before.ok {
			return { repo: $relative, status: $"(ansi red_bold)error: submodule reset failed: ($before.error)(ansi reset)" }
		}

		let porcelain = (git status --porcelain | lines)
		let only_untracked = ($porcelain | all {|line| $line | str starts-with "?? "})
		if ($porcelain | is-empty) or ($untracked and $only_untracked) {
			let result = (git pull | complete)
			if $result.exit_code == 0 {
				# The pull may move the recorded submodule commit.
				let after = (reset-common-submodule)
				if $after.ok {
					{ repo: $relative, status: ($result.stdout | str trim) }
				} else {
					{ repo: $relative, status: $"(ansi red_bold)error: submodule reset failed: ($after.error)(ansi reset)" }
				}
			} else {
				{ repo: $relative, status: $"(ansi red_bold)error: ($result.stderr | str trim)(ansi reset)" }
			}
		} else {
			{ repo: $relative, status: $"(ansi yellow_bold)skipped \(has changes\)(ansi reset)" }
		}
	}
}

export def "repos branch-delete" [] {
	repo-paths
	| each {|it|
		let relative = ($it | path relative-to (pwd))
		cd $it

		# Safe delete only: git refuses unmerged branches, so record those as skipped instead of aborting.
		let results = (
			git branch --verbose
			| lines
			| parse --regex '^[* ] +(?<branch>\S+) +(?<commit>[0-9a-f]+) +(?<tag>\[gone\])? ?(?<message>.*)$'
			| where tag == '[gone]'
			| each {|it|
				let result = (^git branch --delete $it.branch | complete)
				if $result.exit_code == 0 {
					{ branch: $it.branch, deleted: true, error: "" }
				} else {
					{ branch: $it.branch, deleted: false, error: ($result.stderr | lines | first | str trim) }
				}
			}
		)
		for failure in ($results | where deleted == false) {
			print --stderr $"(ansi red_bold)($relative): kept ($failure.branch): ($failure.error)(ansi reset)"
		}
		{
			repo: $relative
			deleted: ($results | where deleted | get branch)
			skipped: ($results | where deleted == false | select branch error)
		}
	}
}

# Forge host and owner/repo parsed from a remote URL (https, ssh:// or scp-like).
def forge-slug [url: string]: nothing -> record<host: string, repo: string> {
	let parsed = ($url | parse --regex '^(?:\w+://)?(?:[^@/]+@)?(?<host>[^/:]+)(?::\d+)?[:/](?<repo>.+?)(?:\.git)?/?$')
	if ($parsed | is-empty) { error make { msg: $"cannot parse remote URL: ($url)" } }
	$parsed | first
}

# Forgejo glob (`*` stays inside a path segment, `**` crosses `/`) as an anchored regex.
# Character classes and alternation are rejected rather than matched wrongly.
def rule-matches [pattern: string, branch: string]: nothing -> bool {
	if ($pattern =~ '[\[\]{}]') {
		error make { msg: $"unsupported glob syntax in branch protection rule '($pattern)'" }
	}
	let regex = (
		$pattern
		| str replace --all --regex '([.+^$()|\\])' '\$1'
		| str replace --all '**' '<DOUBLESTAR>'
		| str replace --all '*' '[^/]*'
		| str replace --all '?' '[^/]'
		| str replace --all '<DOUBLESTAR>' '.*'
	)
	$branch =~ $"^($regex)$"
}

# TODO(FJ-125): replace with `fj repo branch-protection list --branch` once fj iterates repos itself.
# One row per rule across every repo under the cwd; --branch keeps rules whose pattern matches it.
# A repo that fails is reported on stderr with its cause, and the command then errors.
export def "repos branch-protection list" [--branch: string] {
	let results = (
		repo-paths
		| each {|it|
			let relative = ($it | path relative-to (pwd))
			let origin = (^git -C $it remote get-url origin | complete)
			if $origin.exit_code != 0 {
				return { repo: $relative, rules: [], error: $"no origin remote: ($origin.stderr | str trim)" }
			}
			let slug = (forge-slug ($origin.stdout | str trim))
			let listed = (^fj --host $slug.host --format json repo branch-protection $slug.repo list | complete)
			if $listed.exit_code != 0 {
				return { repo: $relative, rules: [], error: ($listed.stderr | str trim) }
			}
			let rules = (
				$listed.stdout
				| from json
				| each {|rule| { host: $slug.host, repo: $slug.repo } | merge $rule }
			)
			{ repo: $relative, rules: $rules, error: "" }
		}
	)

	let rules = (
		$results
		| get rules
		| flatten
		| if $branch == null { $in } else { where {|rule| rule-matches $rule.rule_name $branch } }
	)
	let failures = ($results | where error != "")
	if ($failures | is-empty) { return $rules }

	for failure in $failures {
		print --stderr $"(ansi red_bold)($failure.repo): ($failure.error)(ansi reset)"
	}
	print ($rules | table --expand)
	error make { msg: $"branch protection lookup failed for ($failures | length) repo\(s\)" }
}

# TODO(FJ-125): replace with the fj-native flow once `fj repo branch-protection list --branch` exists.
# Edit the rules piped in from `repos branch-protection list`. --set maps `fj ... edit` flag names
# (underscores for dashes) to values, e.g. `{block_on_outdated_branch: true}`; lists repeat the flag.
export def "repos branch-protection update" [--set: record]: table -> any {
	let rules = $in
	if ($set == null) or ($set | is-empty) {
		error make { msg: "--set is required, e.g. --set {block_on_outdated_branch: true}" }
	}
	let flags = (
		$set
		| items {|key, value|
			let name = $"--($key | str replace --all '_' '-')"
			if ($value | describe | str starts-with "list") {
				$value | each {|item| [$name, ($item | into string)] } | flatten
			} else {
				[$name, ($value | into string)]
			}
		}
		| flatten
	)

	let results = (
		$rules
		| each {|rule|
			for field in [host repo rule_name] {
				if ($rule | get --optional $field) == null {
					error make { msg: $"input row has no '($field)' column; pipe in `repos branch-protection list`" }
				}
			}
			let edited = (^fj --host $rule.host --format json repo branch-protection $rule.repo edit $rule.rule_name ...$flags | complete)
			{
				host: $rule.host
				repo: $rule.repo
				rule_name: $rule.rule_name
				updated: ($edited.exit_code == 0)
				error: ($edited.stderr | str trim)
			}
		}
	)

	let failures = ($results | where updated == false)
	if ($failures | is-empty) { return $results }

	print ($results | table --expand)
	error make { msg: $"branch protection update failed for ($failures | length) rule\(s\)" }
}

def main [command: string, --list, --remote, --untracked] {
	match $command {
		"status" => { repos status --list=$list --remote=$remote }
		"pull" => { repos pull --untracked=$untracked }
		"branch-delete" => { repos branch-delete }
		_ => { print $"Unknown command: ($command)" }
	}
}
