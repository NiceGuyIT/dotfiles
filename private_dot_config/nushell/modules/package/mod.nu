#!/usr/bin/env nu

# Notes:
# twpayne/chezmoi fails because it is not compressed

use std log

export-env {
	# Use this to set the log level.
	$env.NU_LOG_LEVEL = "DEBUG"
}

# github assets get will download the latest GitHub release JSON and return the assets as a record.
def "github assets get" [repo: string]: nothing -> table<record> {
	# TODO: Use this to skip the download and prevent hitting GitHub's rate limit.
	#open $"github-yq.json"
	http get $"https://api.github.com/repos/($repo)/releases/latest"
		| get assets
		| select browser_download_url name content_type size
}

# github asset downloads downloads the GitHub asset and returns a list of files.
def "github asset download" [
	--dest-dir (-d): string,		# Destination directory to save the files
	--remote-name (-f): string,		# Name of the remote file to save locally
	--decompress (-u),			# If true, decompress (uncompress) the files
]: string -> list {
	let url: string = $in
	mut url_name = ($url | (url parse).path | path basename)
	if not ($remote_name | is-empty) {
		$url_name = $remote_name
	}
	let save_file: string = ($dest_dir | path join $url_name)
	log debug $"dest_dir: ($dest_dir)"
	log debug $"url_name: ($url_name)"
	log debug $"save_file: ($save_file)"
	# mkdir doesn't care if the directory exists
	mkdir $dest_dir
	http get $url | save $save_file
	if (not ($decompress | is-empty)) and $decompress {
		# ouch decompresses into exactly one directory EXCEPT if there is only 1 file.
		ouch --yes --quiet --accessible decompress --dir $dest_dir $save_file
		if (ls $dest_dir | where type == dir | length) == 0 {
			# Only 1 file was extracted.
			return (ls $dest_dir | where type == file and name != $save_file | each {|it| ([ $dest_dir $it.name ] | path join)})
		} else {
			let asset_dir = (ls $dest_dir | where type == dir).name.0
			return (ls $asset_dir | where size > 1mb | each {|it| ([ $dest_dir $asset_dir $it.name ] | path join)})
		}
	} else {
		return (ls $save_file | each {|it| ([ $dest_dir $it.name ] | path join)})
	}
}

# github download will return the download URL for the given repo.
def "github download" [
	repo: string			# GitHub repo name in owner/repo format
	--name (-n): string		# Binary name to install. Default: "repo" in "owner/repo"
	--filter (-f): string	# Filter the results if a single release can't be determined
]: nothing -> string {
	mut assets: table<record: any> = (github assets get $repo
		| filter-content-type
		| filter-os
		| filter-arch
	)
	#print ($assets)
	if ($assets | length) == 0 {
		log error $"Filtering by content type, OS and architecture resulted in 0 assets"
		return $assets
	}

	# Check if the asset names use flavors, i.e. musl, gnu, etc., and filter them
	mut flavor: table<record: any> = $assets
	if not ($flavor | is-empty) {
		$flavor = ($assets | filter-flavor $filter)
	} else if ($assets | has-flavor) {
		$flavor = ($assets | filter-flavor)
	}
	if ($flavor | length) == 0 {
		log error "Filtering on flavor resulted in 0 assets. Resetting to previous asset list"
		$flavor = $assets
	}
	$assets = $flavor
	log info "List of assets after filtering for content type, os, arch, and flavor"
	print ($assets | table --width 200)

	mut bin_name: string = ($repo | split column '/' | get column2.0)
	if (not ($name | is-empty)) and ($name | str length) > 0 {
		$bin_name = $name
	}

	# The content_type uniqueness determines if the assets are compressed. If all of them are
	# "application/octet-stream", the assets are uncompressed.
	# Exceptions:
	# This fails for mikefarah/yq due to the following. In this case, prefer the uncompressed over the compressed.
	#   1. The uncompressed binary is called "yq_linux_amd64"
	#   2. Releases contain both compressed and uncompressed binaries.
	if $repo =~ "mikefarah/yq" {
		log info $"Repo ($repo) has mixed assets. Treating as uncompressed"
		let results = ($assets | where content_type == "application/octet-stream" | dl-uncompressed --name 'yq' --filter $filter)
		#print ($results)
		return $results
	} else {
		let ct_count = $assets | get content_type | uniq --count
		log info $"Count of assets by content type"
		print ($ct_count)
		if ($ct_count | length) == 1 and ($ct_count.value.0 == "application/octet-stream") {
			log info $"Repo ($repo) has uncompressed assets"
			let results = ($assets | dl-uncompressed --name $bin_name --filter $filter)
			#print ($results)
			return $results
		} else {
			log info $"Repo ($repo) has compressed assets"
			# Compressed assets need to be filtered by extension.
			let results = ($assets | dl-compressed --name $bin_name --filter $filter)
			#print ($results)
			return $results
		}
	}
	return
}

# install-binaries will install the files into bin_dir
def install-binaries [bin_dir: string, files: list<string>]: nothing -> nothing {
	if ($bin_dir | is-empty) or ($bin_dir | str length) == 0 {
		log error $"bin_dir is not defined: '($bin_dir)'"
		return null
	}
	$files | each {|it|
		let filename: string = ($it | path basename)
		log info $"installing '($it)' to '($bin_dir)'"
		cp $it $bin_dir
		if $nu.os-info.name != "windows" {
			let file = ([$bin_dir, $filename] | path join)
			log info $"Fixing permissions on '($file)'"
			^chmod a+rx,go-w $file
		}
	}
	return null
}

# get-bin-dir will get the bin directory to install the binaries.
def get-bin-dir []: string -> string {
	mut bin_dir = ""
	if $nu.os-info.name == "windows" {
		$bin_dir = ""
	} else {
		# *nix (Linux, macOS, BSD)
		if $env.USER == "root" {
			$bin_dir = "/usr/local/bin"
		} else {
			$bin_dir = $"($env.HOME)/bin"
		}
	}
	return $bin_dir
}

# filter-os will filter out binaries that do not match the current OS
def filter-os []: table<record> -> table<record> {
	let input: table = $in
	# Map the OS to possible OS values in the release names. This is mainly for Apple.
	# os_map: record<linux: list<string>, darwin: list<string>, windows: list<string>>
	let os_map = {
		linux: [
			linux,
			# micro uses "linux64" as the os and arch combined.
			# https://github.com/zyedidia/micro/releases
			#linux64,
		],
		macos: [
			darwin,
			apple,
		],
		windows: [
			windows,
		],
	}
	let os_list = ($os_map | get ($nu.os-info.name))
	let filtered: table = (
		# FIXME: $in throws "Input type not supported."
		$input | where ($os_list | any {|os| $it.name =~ $os })
	)
	if ($env.NU_LOG_LEVEL == "DEBUG") {
		log debug $"Filtered by OS:"
		print ($filtered | select name content_type size)
	}
	return $filtered
}

# filter-arch will filter out binaries that do not match the current architecture
def filter-arch []: table<record> -> table<record> {
	let input: table = $in
	# Map the architecture to possible ARCH values in the release names.
	# arch_map: record<x86_64: list<string>, aarch64: list<string>, arm64: list<string>>
	let arch_map = {
		x86_64: [
			x86_64,
			amd64,
		],
		aarch64: [
			aarch64,
			arm64,
		],
		arm64: [
			arm64,
		],
	}
	let arch_list = ($arch_map | get ($nu.os-info.arch))
	let filtered: table = (
		# FIXME: $in throws "Input type not supported."
		$input | where ($arch_list | any {|arch| $it.name =~ $arch })
	)
	if ($env.NU_LOG_LEVEL == "DEBUG") {
		log debug $"Filtered by architecture:"
		print ($filtered | select name content_type size)
	}
	return $filtered
}

# filter-content-type will filter out non-binary content types.
def filter-content-type []: table<record> -> table<record> {
	let input: table = $in
	# List of acceptable Content-Type values.
	let content_type_list: list<string> = [
		"application/gzip",
		"application/zip",
		"application/x-gtar",
		"application/x-xz",
		"application/octet-stream",
		"binary/octet-stream",
	]
	let filtered: table = (
		$input | where ($content_type_list | any {|ct| $it.content_type == $ct})
	)
	if ($env.NU_LOG_LEVEL == "DEBUG") {
		log debug $"Filtered by content type:"
		print ($filtered | select name content_type size)
	}
	return $filtered
}

# filter-extension will filter out non-binary filenames such as .deb, .rpm, .sha256, .sha512, etc. by selecting only
# valid extensions.
def filter-extension []: table<record> -> table<record> {
	let input: table = $in
	# List of acceptable extensions
	let extension_list: list<string> = [
		"tar.gz",
		"tar.xz",
		"zip",
	]
	let filtered: table = (
		$input | where ($extension_list | any {|ext| $it.name | str ends-with $ext})
	)
	if ($env.NU_LOG_LEVEL == "DEBUG") {
		log debug $"Filtered by extension:"
		print ($filtered | select name content_type size)
	}
	return $filtered
}

# has-flavor will return true if any of the assets have different flavor binaries.
def has-flavor []: table<record> -> bool {
	let input: table = $in
	let flavor_list = [
		"musl",
		"gnu",
		# Nushell has "full"
		#"full",
	]
	let filtered: table = (
		$input | where ($flavor_list | any {|f| $it.name =~ $"\\b($f)\\b" })
	)
	if ($env.NU_LOG_LEVEL == "DEBUG") {
		log debug $"Has flavor: (not ($filtered | length) == 0)"
		print ($filtered | select name content_type size)
	}
	return (not ($filtered | length) == 0)
}

# filter-flavor will filter records based on the binary flavor (musl, gnu, etc.) or the given name.
def filter-flavor [flavor: string = "musl"]: table<record> -> table<record> {
	let input: table = $in
	let filtered: table = (
		$input | where $it.name =~ $"\\b($flavor)\\b"
	)

	if ($filtered | length) == 0 {
		log error "Filtering by flavor resulted in 0 assets"
		print ($filtered)
		return $filtered
	} else if ($filtered | length) == 1 {
		return $filtered
	} else {
		log error "Filtering by flavor resulted in more than 1 asset"
		print ($filtered)
		return $filtered
	}
}

# download-compressed will filter the assets, download, decompress and install it.
def dl-compressed [
	--name (-n): string		# Binary name to install. Default: "repo" in "owner/repo"
	--filter (-f): string	# Filter the results if a single release can't be determined
]: table<record> -> table<record> {
	mut input: table<record: any> = $in

	if ($input | length) > 1 {
		# Compressed assets need to be filtered by extension.
		let filtered: table<record: any> = ($input | filter-extension)
		match ($filtered | length) {
			0 => {
				log error $"Filtering by extension resulted in 0 assets"
				return $filtered
			}
			1 => {
				log info $"Filtering by extension resulted in 1 asset"
				# No additional filtering needed
				$input = $filtered
			}
			_ => {
				log error $"Filtering by extension resulted in 2 or more assets"
				return $filtered
			}
		}
	}

	# $input has exactly 1 record
	let tmp_dir: string = ({ parent: $nu.temp-path, stem: $"package-(random uuid)" } | path join)
	mkdir $tmp_dir
	let files = ($input.browser_download_url.0
		| github asset download --dest-dir $tmp_dir --decompress)
	log info $"Files: ($files)"

	let bin_dir = get-bin-dir
	log debug $"bin_dir: ($bin_dir)"
	install-binaries $bin_dir $files
	rm -r $tmp_dir

	return $input
}

# download-uncompressed will download the uncompressed file and install it.
def dl-uncompressed [
	--name (-n): string		# Binary name to install. Default: "repo" in "owner/repo"
	--filter (-f): string	# Filter the results if a single release can't be determined
]: table<record> -> table<record> {
	let input: table = $in

	if ($input | length) > 1 {
		log error $"Uncompressed assets has 2 or more assets"
		return $input
	}

	# $input has exactly 1 record
	let tmp_dir: string = ({ parent: $nu.temp-path, stem: $"package-(random uuid)" } | path join)
	log debug $"name: ($name)"
	let files = ($input.browser_download_url.0
		| github asset download --dest-dir $tmp_dir --remote-name $name --decompress)
	log info $"Files: ($files)"

	let bin_dir = get-bin-dir
	log debug $"bin_dir: ($bin_dir)"
	install-binaries $bin_dir $files
	rm -r $tmp_dir

	return $input
}

# Search for packages to install
export def search [
	name: string		# Binary to search for
]: nothing -> nothing {
	log info $"Searching packages for '($name)'"
	# TODO: $env.CURRENT_FILE and $env.FILE_PWD do not work in modules. Need to traverse $env.NU_LIB_DIRS
	# to find the module directory. Until this is fixed, use the path relative to $env.HOME
	let packages_filename = ($env.HOME | path join ".config/nushell/modules/package/packages.json")
	let packages = (open $packages_filename)
	$packages
		| where {|it| ($it.repo =~ $"\(?i:($name)\)") or ($it.description =~ $"\(?i:($name)\)")}
}

# Install a package
export def install [
	repo: string			# GitHub repo name in owner/repo format
	--name (-n): string		# Binary name to install. Default: "repo" in "owner/repo"
	--filter (-f): string	# Filter the results if a single release can't be determined
]: nothing -> any {
	# TODO: $env.CURRENT_FILE and $env.FILE_PWD do not work in modules. Need to traverse $env.NU_LIB_DIRS
	# to find the module directory. Until this is fixed, use the path relative to $env.HOME
	let packages_filename = ($env.HOME | path join ".config/nushell/modules/package/packages.json")
	let packages = (open $packages_filename)
	let pkg = ($packages | where {|it| $it.repo =~ $repo})
	if ($pkg | length) > 1 {
		log warning $"Multiple packages found for '($repo)'"
		$pkg
		return
	} else if 1 == ($pkg | length) {
		log info $"Installing ($pkg.repo)"
		if not ($name | is-empty) {
			log info $"Name: ($name)"
		}
		if not ($filter | is-empty) {
			log info $"Filter: ($filter)"
		}

		github download --name $pkg.name?.0 --filter $pkg.filter?.0 $pkg.repo.0
	} else {
		log info $"No packages found for '($repo)'. Attempting download anyway"
		if not ($name | is-empty) {
			log info $"Name: ($name)"
		}
		if not ($filter | is-empty) {
			log info $"Filter: ($filter)"
		}

		github download --name $name --filter $filter $repo
	}

}


# Package module
export def main [
	action: string			# Action to take: search, download, install
	repo: string			# GitHub repo name in owner/repo format
	--name (-n): string		# Binary name to install. Default: "repo" in "owner/repo"
	--filter (-f): string	# Filter the results if a single release can't be determined
]: nothing -> nothing {
	use std log

	if $action == "search" {
		# Search for a package.
		log info $"Searching for package: '($repo)'"
		search $repo
	
	} else if $action == "download" {
		# Download the package into the current directory.
		log info $"Downloading ($repo)"
		print (github download --name $name --filter $filter $repo)
	
	} else if $action == "install" {
		# Install a package into the into the bin directory for the user or system.
		log info $"Installing package: '($repo)'"
		install --name $name --filter $filter $repo
	}

}


# This is from a discord conversation.
# Nushell does not really use exit to stop a script, the way to go imo is to use
#   - return to return a value
#   - errors to stop
#
# def main [] {
#     if something {
#         error make { ... }
#     }
#
#     ...
#
#     if some_other_thing {
#         return $early
#     }
#
#     ...
#
#     $output_value
# }
