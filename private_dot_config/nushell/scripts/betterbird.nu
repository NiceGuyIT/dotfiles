# Install Betterbird
export def "betterbird install" [
	--install-directory: path,
	--applications-directory: path,
]: nothing -> nothing {
	let is_macos = $nu.os-info.name == "macos"

	let install_directory = (
		$install_directory
		| default (if $is_macos { "~/Applications" } else { "~/.local/share" })
		| path expand
	)
	let applications_directory = (
		$applications_directory
		| default (if $is_macos { "~/Applications" } else { "~/.local/share/applications" })
		| path expand
	)

	let os = (
		if $is_macos {
			if $nu.os-info.arch == "aarch64" { "mac-arm64" } else { "mac" }
		} else {
			$nu.os-info.name
		}
	)
	let lang = "en-US"
	let version = (if $is_macos { "128.14.0esr-bb32" } else { "128.9.2esr" })

	# Add the --ProfileManager switch to always start the profile manager.
	let profile_manager = true
	let profile_manager_str = (if ($profile_manager) {'--ProfileManager'} else {''})

	# Application specific names
	let app = {
		name: "Betterbird"
		bin: (if $is_macos { "Betterbird" } else { "betterbird-bin" })
		desktop_name: "eu.betterbird.Betterbird.desktop"
		desktop_exec: "betterbird/betterbird"
		desktop_icon: "betterbird/chrome/icons/default/default256.png"
	}

	if not $is_macos {
		if (^ouch --version) != 'ouch 0.5.1' {
			print "ouch 0.6.1 had a breaking change that changes how the --dir option handles directories."
			print "Previous versions moved the old directory into the --dir directory."
			print "New versions (0.6.1 and possibly 0.6.0) REPLACES the --dir directory."
			print "See https://github.com/ouch-org/ouch/issues/813"
			print ""
			print "ouch 0.5.1 is supported. Please install ouch 0.5.1 and try again."
			return
		}
	}

	# Check if the app is running
	if (ps --long | where name =~ $app.bin | length) > 0 {
		print $"Application ($app.name) is already running"
		return
	}

	# Resolve the download URL.
	# macOS: direct URL to MacDiskImage directory
	#   https://www.betterbird.eu/downloads/MacDiskImage/betterbird-128.14.0esr-bb32.en-US.mac-arm64.dmg
	# Linux: redirect via get.php
	#   https://www.betterbird.eu/downloads/get.php?os=linux&lang=en-US&version=128.9.2esr
	let url = (if $is_macos {
		let filename = $"betterbird-($version).($lang).($os).dmg"
		$"https://www.betterbird.eu/downloads/MacDiskImage/($filename)"
	} else {
		let bin_url = {
			scheme: https,
			host: www.betterbird.eu,
			path: downloads/get.php,
			params: {
				os: $os,
				lang: $lang,
				version: $version,
			}
		} | url join
		http get --full --allow-errors --redirect-mode manual $bin_url
		| get headers.response
		| where name == "location"
		| get 0.value
	})
	let filename = ($url | url parse | get path | path basename)
	let tmp_dl = $nu.temp-dir | path join $filename

	print $"Downloading ($url)"
	http get $url | save --force --progress $tmp_dl

	if $is_macos {
		betterbird install-macos $tmp_dl $install_directory
	} else {
		betterbird install-linux $tmp_dl $install_directory $applications_directory $app $profile_manager_str
	}

	rm $tmp_dl
}

# Install Betterbird on macOS from a .dmg file
def "betterbird install-macos" [
	dmg_path: path,
	install_directory: path,
]: nothing -> nothing {
	let mount_point = $nu.temp-dir | path join "betterbird-dmg"
	mkdir $mount_point

	print $"Mounting ($dmg_path)"
	^hdiutil attach $dmg_path -mountpoint $mount_point -nobrowse -quiet

	let app_name = (
		ls $mount_point
		| where name =~ '\.app$'
		| get 0.name
		| path basename
	)

	let source = ($mount_point | path join $app_name)
	let destination = ($install_directory | path join $app_name)

	if ($destination | path exists) {
		print $"Removing existing ($destination)"
		rm --recursive $destination
	}

	print $"Copying ($app_name) to ($install_directory)"
	cp --recursive $source $install_directory

	print $"Unmounting ($mount_point)"
	^hdiutil detach $mount_point -quiet

	print $"Betterbird installed to ($destination)"
}

# Install Betterbird on Linux from a tar archive
def "betterbird install-linux" [
	archive_path: path,
	install_directory: path,
	applications_directory: path,
	app: record,
	profile_manager_str: string,
]: nothing -> nothing {
	# https://github.com/Betterbird/thunderbird-patches/blob/main/install-on-linux/install-betterbird.sh#L101
	let desktop_url = {
		scheme: https,
		host: raw.githubusercontent.com,
		path: /Betterbird/thunderbird-patches/main/metadata/eu.betterbird.Betterbird.desktop,
	} | url join

	print $"Extracting the archive to `($install_directory)`"
	ouch decompress --accessible --yes --dir $install_directory $archive_path

	print "Installing desktop file..."
	http get $desktop_url
		| lines
		| str replace --regex '^Exec=.*' $"Exec=($install_directory | path join $app.desktop_exec) ($profile_manager_str)"
		| str replace --regex '^Icon=.*' $"Icon=($install_directory | path join $app.desktop_icon)"
		| to text
		| save --force ($applications_directory | path join $app.desktop_name)
}
