# Install Betterbird
export def "betterbird install" [
	--install-directory: path,
	--application-directory: path,
]: nothing -> nothing {
	# Define defaults
	let default_install_dir = (
		match $nu.os-info.name {
			"macos" => {"~/Applications/" | path expand}
			# TODO: Add Windows
			_ => {"~/.local/share/" | path expand}
		}
	)
	let default_application_dir = (
		match $nu.os-info.name {
			"macos" => {"~/Library/Betterbird/" | path expand}
			# TODO: Add Windows
			_ => {"~/.local/share/applications" | path expand}
		}
	)

	let install_directory = ($install_directory | default $default_install_dir| path expand)
	let application_directory = ($application_directory | default $default_application_dir | path expand)
	let os = (match $nu.os-info.name {
	    "macos" => (if $nu.os-info.arch == "aarch64" {"mac-arm64"} else {"mac"})
	    _ => $nu.os-info.name
	})
	let lang = "en-US"
	let version = "release"

	# Application specific names
	let app = {
		name: "Betterbird"
		bin: "betterbird-bin"
		desktop_name: "eu.betterbird.Betterbird.desktop"
		desktop_exec: "betterbird/betterbird"
		desktop_icon: "betterbird/chrome/icons/default/default256.png"
	}

	# URL format:
	# Base: https://www.betterbird.eu/downloads/get.php?os=linux&lang=en-US&version=release
	# Parameters:
	#   os: linux | mac | mac-arm64
	#   lang: en-US
	#   version: release
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

	# https://github.com/Betterbird/thunderbird-patches/blob/main/install-on-linux/install-betterbird.sh#L101
	let desktop_url = {
		scheme: https,
		host: raw.githubusercontent.com,
		path: /Betterbird/thunderbird-patches/main/metadata/eu.betterbird.Betterbird.desktop,
	} | url join

	# Check if the app is running
	if (ps --long | where name =~ $app.bin | length) > 0 {
		print $"Application ($app.name) is already running"
		return
	}

	# Get the redirect location.
	let url = (
		http get --full --allow-errors --redirect-mode manual $bin_url
		| get headers.response
		| where name == "location"
		| get 0.value
	)
	let filename = ($url | url parse | get path | path basename)
	let tmp_dl = $nu.temp-path | path join $filename

	print $"Downloading ($url)"
	http get $url | save --force --progress $tmp_dl

	print $"Extracting the archive to `($install_directory)`"
	ouch decompress --accessible --yes --dir $install_directory $tmp_dl
	rm $tmp_dl

	print "Installing desktop file..."
	http get $desktop_url
		| lines
		| str replace --regex '^Exec=.*' $"Exec=($install_directory | path join $app.desktop_exec)"
		| str replace --regex '^Icon=.*' $"Icon=($install_directory | path join $app.desktop_icon)"
		| to text
		| save --force ($application_directory | path join $app.desktop_name)
}
