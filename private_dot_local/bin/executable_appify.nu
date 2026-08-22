#!/usr/bin/env nu

# Appify: create the simplest possible macOS app bundle that runs a script.
# Nushell port of bin-old/appify/appify.sh (Thomas Aylott / Mathias Bynens / Andrew Dvorak / Duncan McGreggor).
# https://gist.github.com/oubiwann/453744744da1141ccc542ff75b47e0cf

const VERSION = "4.1.0"
export const DEFAULT_ICON = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns"

# Build a macOS .app bundle at ./<name>.app that runs `script`. Shared by this
# script's CLI and by other appify-* wrapper scripts (e.g. appify-firefox.nu).
export def build-app-bundle [
	script: string   # Path of the script to appify
	name: string   # Name of the application
	icons: string = $DEFAULT_ICON   # Icon file (.icns) to use
] {
	if not ($script | path exists) or (($script | path type) != "file") {
		print --stderr $"ERROR: can't find the script '($script)'"
		exit 1
	}

	if not ($icons | path exists) {
		print --stderr $"ERROR: can't find the icons file '($icons)'"
		exit 1
	}

	let app_dir = $"($name).app"
	if ($app_dir | path exists) {
		print --stderr $"ERROR: the bundle '(pwd | path join $app_dir)' already exists"
		exit 1
	}

	let contents_dir = ($app_dir | path join "Contents")
	let macos_dir = ($contents_dir | path join "MacOS")
	let resources_dir = ($contents_dir | path join "Resources")
	let exe_path = ($macos_dir | path join $name)

	mkdir $macos_dir
	mkdir $resources_dir

	cp $icons ($resources_dir | path join $"($name).icns")
	cp $script $exe_path
	^chmod +x $exe_path

	# LSRequiresNativeExecution forces a native-architecture launch. Without it, Launch
	# Services can't infer an architecture from a script executable (it isn't Mach-O) and
	# silently falls back to launching the app under Rosetta.
	let info_plist = $"<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>
<plist version='1.0'>
  <dict>
    <key>CFBundleExecutable</key>
    <string>($name)</string>
    <key>CFBundleGetInfoString</key>
    <string>($name)</string>
    <key>CFBundleIconFile</key>
    <string>($name)</string>
    <key>CFBundleName</key>
    <string>($name)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>4242</string>
    <key>LSRequiresNativeExecution</key>
    <true/>
  </dict>
</plist>
"
	$info_plist | save ($contents_dir | path join "Info.plist")

	print $"Application bundle created at '(pwd | path join $app_dir)'"
}

# Create a macOS .app bundle that runs a script.
#
# Note that you cannot rename appified apps. If you want a custom name, pass --name.
def main [
	--script (-s): string   # Path of the script to appify (required)
	--name (-n): string = "My App"   # Name of the application
	--icons (-i): string = $DEFAULT_ICON   # Icon file (.icns) to use
	--version (-v)   # Print the version and exit
] {
	if $version {
		print $"appify.nu v($VERSION)"
		return
	}

	if $script == null {
		print --stderr "ERROR: the script to appify must be provided! Use --script <path>."
		exit 1
	}

	build-app-bundle $script $name $icons
}
