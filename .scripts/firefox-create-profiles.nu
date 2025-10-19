#!/usr/bin/env -S nu --plugins '[/usr/local/bin/nu_plugin_formats]'

# Create the Firefox profiles
def firefox-create-profiles []: nothing -> nothing {
	use std log
	# This script will create a desktop icon for every Firefox profile on Linux.

	const desktop_file = '/usr/share/applications/firefox.desktop'
	let firefox_dir = ($env.HOME | path join '.mozilla/firefox')
	
	# 'from ini' requires formats plugin
	let formats = (which nu_plugin_formats | get path?.0?)
	plugin add $formats
	plugin use formats
	let profiles = ($firefox_dir | path join 'profiles.ini')
	let profile_paths = (open $profiles
		| transpose section value
		| where section =~ "Profile"
		| where value.Path !~ "default"
		| select section value.Path
		| rename section path
		| insert name {|it|
			if ($it.path =~ '\.') {
				$it.path
				| split column '.'
				| get column2?.0
			} else {
				$it.path
			}
		}
	)

	let script_sir = ($env.CHEZMOI_WORKING_TREE | path join ".scripts")
	let user_js = ([$env.CHEZMOI_WORKING_TREE ".scripts"] | path join 'mozilla-firefox-user.js')
	let app_dir = ([$env.HOME .local share applications] | path join)
	if not ($app_dir | path exists) {
		mkdir $app_dir
	}
	$profile_paths | each {|it|
		let filename = ($app_dir | path join $"firefox-($it.name).desktop")
		open $desktop_file
			| lines
			| str replace --regex '^Exec=(.*) %u' $"Exec=$1 -P \"($it.name)\" %u"
			| str replace --regex '^Name(.*)=(.*)' $"Name$1=$2 \(($it.name)\)"
			| to text
			| save --force $filename
		print $"Saving ($filename)"

		# Copy the user.js file to each profile
		# TODO: Technically this is out off scope for creating the Firefox profile icon.
		cp $user_js ([$firefox_dir $it.path] | path join 'user.js')
	}
}

# Check the environment to see if Firefox profiles should be updated.
def check-environment []: nothing -> nothing {
	use std log
	const desktop_file = '/usr/share/applications/firefox.desktop'
	
	if not ($nu.plugin-path | path exists) {
		log warning $"Chezmoi has not run yet to create Nu's plugin path: ($nu.plugin-path)"
		print $"Chezmoi has not run yet to create Nu's plugin path: ($nu.plugin-path)"
		exit 0
	}

	let firefox_bin = (which firefox | get path?.0?)
	if ($firefox_bin | is-empty) {
		log warning $"Firefox binary was not found in path: ($firefox_bin)"
		print $"Firefox binary was not found in path: ($firefox_bin)"
		exit 0
	}

	if ($desktop_file | is-empty) {
		log warning $"Sample Firefox desktop file not found: ($desktop_file)"
		print $"Sample Firefox desktop file not found: ($desktop_file)"
		exit 0
	}

	let firefox_dir = ($env.HOME | path join '.mozilla/firefox')
	if ($firefox_dir | is-empty) {
		log warning $"Firefox config directory not found: ($firefox_dir)"
		print $"Firefox config directory not found: ($firefox_dir)"
		exit 0
	}

	let profiles = ($firefox_dir | path join 'profiles.ini')
	if ($profiles | is-empty) {
		log warning $"Firefox profiles was not found in config: ($profiles)"
		print $"Firefox profiles was not found in config: ($profiles)"
		exit
	}
}

export def "main" [] {
	# 'from ini' requires formats plugin
	let formats = (which nu_plugin_formats | get path?.0?)
	if ($formats | is-empty) or not ($formats | path exists) {
		log warning "Plugin nu_plugin_formats is not installed"
		print "Plugin nu_plugin_formats is not installed"
		exit 0
	}

	plugin add $formats
	plugin list

	if (check-environment) {
		firefox-create-profiles
	}
}
