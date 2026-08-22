#!/usr/bin/env nu

# Create a macOS .app that launches Firefox with a specific profile, via appify.nu.

use appify.nu [build-app-bundle]

const FIREFOX_ICON = "/Applications/Firefox.app/Contents/Resources/firefox.icns"

# Create a macOS .app that launches Firefox with a given profile.
def main [
	--profile (-p): string   # Firefox profile name to launch (required)
	--name (-n): string   # Application name (default: "firefox-<profile>")
	--icons (-i): string = $FIREFOX_ICON   # Icon file (.icns) to use
] {
	if $profile == null {
		print --stderr "ERROR: the Firefox profile name must be provided! Use --profile <name>."
		exit 1
	}

	let app_name = if $name == null { $"firefox-($profile)" } else { $name }

	let launcher = $"#!/usr/bin/env zsh

# https://stackoverflow.com/questions/9392052/open-multiple-firefox-instances-with-different-profiles-on-mac-os-x

# https://bugzilla.mozilla.org/show_bug.cgi?id=1653218
# As for the 'firefox instance is already running' message, this is correct. Passing -no-remote on
# the command line instructs Firefox to not listen for links opened from other applications. As a
# general rule you should not use -no-remote.

# http://kb.mozillazine.org/Command_line_arguments

# macOS Launch Services can't read an architecture out of a shell-script app bundle: it flags the
# bundle 'shell-script', silently drops LSRequiresNativeExecution from Info.plist, and launches it
# under Rosetta. That translated state is inherited by whatever this script execs next, so pin
# Firefox to the Mac's real native architecture. sysctl reports genuine hardware, even under Rosetta.
native_arch=arm64
if [ \"\$\(sysctl -n hw.optional.arm64 2>/dev/null\)\" != \"1\" ]; then
	native_arch=x86_64
fi

#arch -arch \"\$native_arch\" /Applications/Firefox.app/Contents/MacOS/firefox -P '($profile)' -no-remote \"${1}\" &
arch -arch \"\$native_arch\" /Applications/Firefox.app/Contents/MacOS/firefox -P '($profile)' &
"

	let tmp_script = (^mktemp | str trim)
	$launcher | save --force $tmp_script
	^chmod +x $tmp_script

	build-app-bundle $tmp_script $app_name $icons

	rm $tmp_script
}
