# Custom Zypper functions

# Search for packages with zypper and return a table.
export def "zypper search" [
	--installed (-i)			# Search only installed packges
	--type (-t): string			# Search for the given type
	...names: string			# Names to search
]: nothing -> table {
	let zypp_args = [
		--xmlout
		--quiet
	]
	mut args = [
		--details
	]
	if ($installed | is-not-empty) and ($installed == true) {
		$args = ($args | append "--installed-only")
	}
	if ($type | is-not-empty) {
		$args = ($args | append ["--type" $type])
	}

	let parsed = (
		^zypper ...$zypp_args search ...$args ...$names
		| collect
		| from xml
	)
	# On no match zypper emits <message>No matching items found.</message> instead of
	# a <search-result>/<solvable-list>. Return an empty list in that case.
	if ($parsed.content.0.tag? | default "") != "search-result" {
		return []
	}
	$parsed | get content.0.content.0.content.attributes
	#| reject status kind arch
}

# List packages available in the given repositories and return a table.
export def "zypper packages" [
	--installed (-i)			# Show only installed packages
	--not-installed (-u)		# Show only packages which are not installed
	--orphaned					# Show orphaned system packages
	--autoinstalled				# Show packages auto-selected by the resolver
	--userinstalled				# Show packages explicitly selected by the user
	--unneeded					# Show packages which are not needed
	...repos: string			# Repositories to limit the listing to
]: nothing -> table {
	let zypp_args = [
		--xmlout
		--quiet
	]
	mut args = []
	if $installed {
		$args = ($args | append "--installed-only")
	}
	if $not_installed {
		$args = ($args | append "--not-installed-only")
	}
	if $orphaned {
		$args = ($args | append "--orphaned")
	}
	if $autoinstalled {
		$args = ($args | append "--autoinstalled")
	}
	if $userinstalled {
		$args = ($args | append "--userinstalled")
	}
	if $unneeded {
		$args = ($args | append "--unneeded")
	}

	# Debugging
	#print $"zypper (echo ...$zypp_args) packages (echo ...$args) (echo ...$repos)"

	# `zypper packages` ignores --xmlout and emits a pipe-separated text table, so
	# parse it by hand. Data rows start with a lowercase status char (i, v, ...)
	# followed by whitespace and `|`, which skips the blank line, the header
	# (`S  | ...`), and the `---+---` separator.
	^zypper ...$zypp_args packages ...$args ...$repos
	| collect
	| from xml
	| get content.0.content
	| lines
	| where $it !~ '-{5,}'
	| to text
	| from csv --separator '|' --trim all
	| rename status repo name version arch
	| update status {|row|
		match $row.status {
			'i+' => 'user-installed'
			'i' => 'auto-installed'
			'v' => 'other-version'
			'!' => 'a patch in needed state'
			'.l' => 'is shown in the 2nd column if the item is locked (see section Package Locks Management)'
			'.P' => 'is shown in the 2nd column if the item is part of a PTF'
			'.R' => 'is shown in the 2nd column if the item has been retracted'
			_ => 'not-installed'
		}
	}
}
