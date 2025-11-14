#!/usr/bin/env nu

# Check if the system uses musl libc instead of glibc
def is-musl []: nothing -> bool {
	if ($"/lib/libc.musl-($nu.os-info.arch).so.1" | path exists) {
		return true
	}
	try {
		^ldd /bin/ls | str contains "musl" | ignore
	} catch {
		return false
	}
	return false
}

def 'claude download' [
	target: string				# Target version to install
	download_dir: string		# Download directory
	gcs_bucket: string			# GCS Bucket for Claude
]: nothing -> string {
	use std log

	log info $"downloading Claude"
	# Create download directory
	if not ($download_dir | path exists) {
		mkdir $download_dir
	}

	# Detect platform
	let os = match $nu.os-info.name {
		"macos" => "darwin",
		"linux" => "linux",
		_ => {
			log error "Windows is not supported"
			exit 1
		}
	}

	let arch = match $nu.os-info.arch {
		"x86_64" | "amd64" => "x64",
		"aarch64" | "arm64" => "arm64",
		_ => {
			log error $"Unsupported architecture: ($nu.os-info.arch)"
			exit 1
		}
	}

	# Check for musl on Linux and adjust platform accordingly
	let platform = match $os {
		"linux" => {
			if (is-musl) {
				$"linux-($arch)-musl"
			} else {
				$"linux-($arch)"
			}
		},
		_ => $"($os)-($arch)"
	}

	# Always download stable version (which has the most up-to-date installer)
	log info "Downloading version information..."
	let version = (http get ($gcs_bucket | path join "stable"))

	# Download manifest and extract checksum
	log info "Downloading manifest..."
	let manifest_json = (http get ($gcs_bucket | path join $version "manifest.json"))

	# Extract checksum
	let checksum = ($manifest_json | get platforms | get $platform | get checksum)

	# Validate checksum format (SHA256 = 64 hex characters)
	if ($checksum | is-empty) {
		log error $"Platform ($platform) not found in manifest"
		exit 1
	}

	# Download binary
	let binary_path = ($download_dir | path join $"claude-($version)-($platform)")
	if ($binary_path | path exists) and (open --raw $binary_path | hash sha256) == $checksum {
		log info $"Previous download exists: ($binary_path)"
		return $binary_path
	}

	log info $"Downloading Claude Code ($version) for ($platform)..."

	try {
		http get ($gcs_bucket | path join $version $platform "claude") | save $binary_path
	} catch {
		log error "Download failed"
		try { rm $binary_path }
		exit 1
	}

	# Verify checksum
	log info "Verifying checksum..."
	if (open --raw $binary_path | hash sha256) != $checksum {
		log error "Checksum verification failed"
		exit 1
	}

	# Make executable
	chmod a+x $binary_path
	log info $"Claude has been downloaded to ($binary_path)"
	$binary_path
}

# Install Claude Code
def 'claude install' [
	target: string				# Target version to install
	binary_path: string			# Full path of the binary
] {
	use std log
	# Run claude install to set up launcher and shell integration
	log info "Setting up Claude Code..."

	if ($target | is-not-empty) {
		^$binary_path install $target
	} else {
		^$binary_path install
	}
}

# Claude Code Bootstrap Script (Nushell version)
def main [
	target?: string = 'stable'			# Target version to install
] {
	use std log

	const GCS_BUCKET = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
	let download_dir = ($env.HOME | path join ".claude/downloads")
	let target = ($target | default 'stable')


	# Validate target if provided
	let valid_pattern = '^(stable|latest|[0-9]+\.[0-9]+\.[0-9]+(-[^[:space:]]+)?)$'
	if ($target | parse --regex $valid_pattern | length) == 0 {
		log error $"Usage: ($env.CURRENT_FILE) [stable|latest|VERSION]"
		exit 1
	}

	let binary_path = claude download $target $download_dir $GCS_BUCKET
	# claude install $target $binary_path

	log info ""
	log info "✅ Installation complete!"
	log info ""
}
