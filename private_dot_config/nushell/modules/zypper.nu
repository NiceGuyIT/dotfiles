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

	# Validate the given repo aliases against `zypper repos` before invoking
	# zypper, so the user gets one friendly message instead of zypper's noisy
	# "Repository '<name>' not found by its alias, number, or URI." for each arg.
	if ($repos | is-not-empty) {
		let defined = (zypper repos | get Alias)
		let missing = ($repos | where {|r| $r not-in $defined})
		if ($missing | is-not-empty) {
			print $"(ansi red)Error:(ansi reset) unknown repository alias: ($missing | str join ', ')"
			print $"(ansi cyan)Hint:(ansi reset) run `zypper repos` to see the defined repositories"
			return
		}
	}

	# Debugging
	#print $"zypper (echo ...$zypp_args) packages (echo ...$args) (echo ...$repos)"

	# `zypper packages` ignores --xmlout and emits a pipe-separated text table, so
	# parse it by hand. Data rows start with a lowercase status char (i, v, ...)
	# followed by whitespace and `|`, which skips the blank line, the header
	# (`S  | ...`), and the `---+---` separator.
	let parsed = (
		^zypper ...$zypp_args packages ...$args ...$repos
		| collect
		| from xml
	)
	# On errors (e.g. a disabled repo) zypper returns <message type="error">...</message>
	# instead of the text table. Surface the message as a friendly error and exit.
	if ($parsed.content.0.tag? | default null) == "message" {
		let msg_type = ($parsed.content.0.attributes.type? | default "error")
		let text = ($parsed.content.0.content.0.content? | default "")
		let label = if $msg_type == "error" { "Error" } else { "Info" }
		let color = if $msg_type == "error" { (ansi red) } else { (ansi yellow) }
		print $"($color)($label):(ansi reset) ($text)"
		return
	}
	$parsed
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

# List defined repositories and return a table.
export def "zypper repos" [
	--details (-d)				# Show more information like URI, priority, type
	--uri (-u)					# Show also base URI of repositories
	--priority (-p)				# Show also repository priority
	--show-enabled-only (-E)	# Show enabled repos only
	--sort-by-name (-N)			# Sort the list by name
	--sort-by-priority (-P)		# Sort the list by priority
	...repos: string			# Repositories to limit the listing to
]: nothing -> table {
	let zypp_args = [
		--quiet
	]
	mut args = []
	if $details {
		$args = ($args | append "--details")
	}
	if $uri {
		$args = ($args | append "--uri")
	}
	if $priority {
		$args = ($args | append "--priority")
	}
	if $show_enabled_only {
		$args = ($args | append "--show-enabled-only")
	}
	if $sort_by_name {
		$args = ($args | append "--sort-by-name")
	}
	if $sort_by_priority {
		$args = ($args | append "--sort-by-priority")
	}

	# Debugging
	#print $"zypper (echo ...$zypp_args) repos (echo ...$args) (echo ...$repos)"

	# `zypper repos` emits a pipe-separated text table. Parse it the same way as
	# `zypper packages`: drop the `---+---` separator and any non-data lines
	# (preamble, blanks), then feed the result to `from csv`. The pipe-existence
	# filter also strips the priority preamble that prints when --details is off.
	^zypper ...$zypp_args repos ...$args ...$repos
	| lines
	| where $it !~ '-{5,}'
	| where $it =~ '\|'
	| to text
	| from csv --separator '|' --trim all
}
