#!/usr/bin/env nu

const INSTALL_DIR = ([$nu.home-dir '.local/bin'] | path join)
const BASE_URL = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases'

# Install Claude to ~/.local/bin/
def main [] {
	# Map os-info to Claude's platform naming
	let platform = (
		match [$nu.os-info.name, $nu.os-info.arch] {
			["macos", "aarch64"] => "darwin-arm64",
			["macos", "x86_64"] => "darwin-x64",
			["linux", "x86_64"] => "linux-x64",
			["linux", "aarch64"] => "linux-arm64",
			_ => (
				error make {msg: $"Unsupported platform: ($nu.os-info.name) ($nu.os-info.arch)"}
			)
		}
	)

	let version = (http get $"($BASE_URL)/stable" | str trim)
	let expected_checksum = (
		http get $"($BASE_URL)/($version)/manifest.json"
		| get platforms
		| get $platform
		| get checksum
	)

	mkdir $INSTALL_DIR
	let install_path = ($INSTALL_DIR | path join 'claude')
	http get $"($BASE_URL)/($version)/($platform)/claude" | save --progress $install_path

	let actual_checksum = (open $install_path | hash sha256)
	if $actual_checksum != $expected_checksum {
		rm $install_path
		use std log
		log error $"Checksum mismatch! Expected: '($expected_checksum)'; Got: '($actual_checksum)'"
	}

	chmod +x $install_path
	print $"Claude installed to ($install_path)"
}
