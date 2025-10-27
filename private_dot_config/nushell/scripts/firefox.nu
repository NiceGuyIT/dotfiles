# Install Firefox
export def "firefox install" [
	--install-directory: path = "~/.local/share/",
	--applications-directory: path = "~/.local/share/applications/",
]: nothing -> nothing {
	let install_directory = $install_directory | path expand
	let applications_directory = $applications_directory | path expand
	let lang = "en-US"

	# The Zen Browser docs good information for mapping settings to files.
	# https://docs.zen-browser.app/guides/manage-profiles#2-copy-essential-files

	# All versions: https://download-installer.cdn.mozilla.net/pub/firefox/releases/
	# let version = '128.9.0esr'
	# 128.9.0esr uses bz2 for compression while 140.1.0esr uses xz
	let version = '140.4.0esr'

	let os = $nu.os-info.name
	let arch = $nu.os-info.arch

	# Application specific names
	let app = {
		name: "Firefox"
		bin: "firefox-bin"
		desktop_name: "firefox.desktop"
		desktop_exec: "firefox/firefox"
		desktop_icon: "firefox/chrome/icons/default/default256.png"
	}

	if (^ouch --version) != 'ouch 0.5.1' {
		print "ouch 0.6.1 had a breaking change that changes how the --dir option handles directories."
		print "Previous versions moved the old directory into the --dir directory."
		print "New versions (0.6.1 and possibly 0.6.0) REPLACES the --dir directory."
		print "See https://github.com/ouch-org/ouch/issues/813"
		print ""
		print "ouch 0.5.1 is supported. Please install ouch 0.5.1 and try again."
		return
	}

	if ($install_directory | path exists) {
		print "IMPORTANT: This script is not complete."
		print "The current version downloads Firefox to ~/.local/share/firefox"
		print "This directory currently exists. Delete the Firefox install directory and try again."
		return
	}

	# URL format:
	# Base: https://download-installer.cdn.mozilla.net/pub/firefox/releases/140.4.0esr/linux-x86_64/en-US/firefox-140.4.0esr.tar.xz
	# Parameters:
	#   os: linux | mac | mac-arm64
	#   lang: en-US
	let url = {
		scheme: https,
		host: download-installer.cdn.mozilla.net,
		path: (
			[
				'pub/firefox/releases'
				$version
				([$os $arch] | str join '-')
				$lang
				$"firefox-($version).tar.xz"
			] | path join
		)
	} | url join

	# # https://github.com/Betterbird/thunderbird-patches/blob/main/install-on-linux/install-betterbird.sh#L101
	# let desktop_url = {
	# 	scheme: https,
	# 	host: raw.githubusercontent.com,
	# 	path: /Betterbird/thunderbird-patches/main/metadata/eu.betterbird.Betterbird.desktop,
	# } | url join

	# Check if the app is running
	if (ps --long | where name =~ $app.bin | length) > 0 {
		print $"Application ($app.name) is already running"
		return
	}

	# Get the redirect location.
	let filename = ($url | url parse | get path | path basename)
	let tmp_dl = $nu.temp-path | path join $filename

	print $"Downloading ($url)"
	http get $url | save --force --progress $tmp_dl

	print $"Extracting the archive to `($install_directory)`"
	ouch decompress --accessible --yes --dir $install_directory $tmp_dl
	rm $tmp_dl

	# print "Installing desktop file..."
	# http get $desktop_url
	# 	| lines
	# 	| str replace --regex '^Exec=.*' $"Exec=($install_directory | path join $app.desktop_exec)"
	# 	| str replace --regex '^Icon=.*' $"Icon=($install_directory | path join $app.desktop_icon)"
	# 	| to text
	# 	| save --force ($applications_directory | path join $app.desktop_name)
}
