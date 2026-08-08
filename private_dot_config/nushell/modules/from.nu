# Parsers for common system file formats.
#
# Naming: one command per format, named after the format, never after a path.
# Input is always the raw text, so the same parser works on /etc/fstab, a copy
# under /mnt, or a file pulled off a backup. Path-aware wrappers live in etc.nu.

# Parse fstab-format text (/etc/fstab, /etc/mtab) into a table.
# The 'dump' and 'pass' fields are optional in the format and default to 0.
export def "from fstab" []: string -> table {
	lines
	| each {|line| $line | str trim}
	| where {|line| ($line | is-not-empty) and not ($line | str starts-with "#")}
	| each {|line|
		let field = $line | split row --regex '\s+'
		{
			device: ($field | get 0)
			mountpoint: ($field | get 1)
			fs_type: ($field | get 2)
			options: ($field | get 3 | split row ",")
			dump: ($field | get --optional 4 | default "0" | into int)
			pass: ($field | get --optional 5 | default "0" | into int)
		}
	}
}

# Parse os-release-format text (/etc/os-release, /usr/lib/os-release) into a record.
# Values may be quoted or bare; both forms are valid per os-release(5).
export def "from os-release" []: string -> record {
	lines
	| each {|line| $line | str trim}
	| where {|line| ($line | is-not-empty) and not ($line | str starts-with "#")}
	| parse --regex '^(?<name>[A-Za-z_][A-Za-z0-9_]*)=(?<value>.*)$'
	| update value {|row| $row.value | str trim --char '"' | str trim --char "'"}
	| transpose --header-row --as-record
}
