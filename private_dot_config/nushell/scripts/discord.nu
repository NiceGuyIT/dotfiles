# Install discord
# Original pulled from https://github.com/amtoine/dotfiles/blob/main/.config/discord/install.nu
# Removed bin-directory
# Replace tar with ouch
# Fix icon in discord.desktop
export def "discord install" [
	--platform: string = "linux",
	--format: string = "tar.gz",
	--install-directory: path = "~/.local/share/Discord/",
	--applications-directory: path = "~/.local/share/applications/",
]: nothing -> nothing {
	let install_directory = ($install_directory | path expand)
	let applications_directory = ($applications_directory | path expand)

	if (^ouch --version) != 'ouch 0.5.1' {
		print "ouch 0.6.1 had a breaking change that changes how the --dir option handles directories."
		print "Previous versions moved the old directory into the --dir directory."
		print "New versions (0.6.1 and possibly 0.6.0) REPLACES the --dir directory."
		print "See https://github.com/ouch-org/ouch/issues/813"
		print ""
		print "ouch 0.5.1 is supported. Please install ouch 0.5.1 and try again."
		return
	}

	let url = {
		scheme: https,
		host: discord.com,
		path: /api/download,
		params: {
			platform: $platform,
			format: $format,
		}
	} | url join
	let tmp_dl = (mktemp --tmpdir-path ($install_directory | path dirname) "Discord-XXXX.tar.gz")

	# FIXME: The general download didn't work on one computer.
	# This version uses xh to get the Location header to download.
	# The download can be verified with the following.
	# open discord-0.0.38.tar.gz | hash md5 --binary | encode base64
	# which matches header:
	# x-goog-hash: md5=9SDtJ2xlngeoWOHx/xoFgA==
	#let location = (
	#	^xh --headers $"(url)"
	#		| lines
	#		| parse "{header}: {value}"
	#		| where header == location
	#		| get value.0
	#)

	# Remove the current install directory due to the Ouch bug above.
	if ($install_directory | path exists) {
		print $"Removing current install directory: '($install_directory)'"
		rm -r $install_directory
	}
	print $"Downloading ($url)"
	print $"tmp_dl: ($tmp_dl)"
	# See https://github.com/ouch-org/ouch/issues/813
	print $"install_directory: ($install_directory)"
	http get $url | save --force --progress $tmp_dl

	# Note: The --dir option creates a subdirectory rather then use the directory given.
	# The safer option is to not use --dir and make sure $tmp_dl matches the Discord-XXX.tar.gz format (above).
	cd ($install_directory | path dirname)
	print $"Extracting the archive to `($install_directory)`"
	^ouch decompress --accessible --yes $tmp_dl
	rm $tmp_dl

	print "Installing desktop file..."
	open ($install_directory | path join "discord.desktop")
		| lines
		| str replace --regex '^Exec=.*' $"Exec=($install_directory | path join "Discord")"
		| str replace --regex '^Icon=.*' $"Icon=($install_directory | path join "discord.png")"
		| to text
		| save --force ($applications_directory | path join "discord.desktop")
}
