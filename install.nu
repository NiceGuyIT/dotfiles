#!/usr/bin/env nu

use std log
$env.NU_LOG_LEVEL = DEBUG

# Install the git hooks
def "install git hooks" []: nothing -> nothing {
	(install symlink
		--target "../../git-hooks/post-merge"
		--directory ([$env.PWD ".git" "hooks"] | path join)
	)
	return
}

# install symlink will "install" or create the symlink in "directory" pointing to "target" with the optional "name".
# The Unix "ln" command defines the source and target conceptually reverse of the actual implementation.
# This command
#   ln -s source target
# results in the following listing
#   lrwxrwxrwx 1 dev users 6 Dec  9 15:30 target -> source
# and in Nushell the target is the name while the source is the target.
# ╭───┬────────┬─────────┬────────╮
# │ # │  name  │  type   │ target │
# ├───┼────────┼─────────┼────────┤
# │ 0 │ target │ symlink │ source │
# ╰───┴────────┴─────────┴────────╯
def "install symlink" [
	--directory: path		# Directory is the location of the symlink.
	--target: string		# Target of the symlink. Can be file or directory.
	--name: string			# (Optional) Name of the symlink.
	--force: bool = false	# If true, forcefully install the symlink.
]: nothing -> nothing {
	mut directory = $directory | path expand
	# Expanding the target path prevents relative paths.
	let target = $target

	# Install the git-hook
	if not ($directory | path exists) {
		log error $"directory directory does not exist: ($directory)"
		error make {msg: $"directory directory does not exist: ($directory)"}
	}

	if not ([$directory $target] | path join | path exists) {
		log error $"Target file/directory does not exist: ($target)"
		error make {msg: $"Target file/directory does not exist: ($target)"}
	}

	# Check if the symlink exists
	if ([$directory ($target | path basename)] | path join | path exists) {
		log info $"Symlink already exists in directory: ($directory)"
		# error make {msg: $"Symlink already exists in directory: ($directory)"}
		return
	}

	# Append the name if it exists.
	if not ($name | is-empty) {
		$directory = ($directory | path join $name)
	}

	log info $"Installing symlink: ($target)"
	if $force {
		^ln [
			--symbolic --force
			$target
			$directory
		]	
	} else {
		^ln [
			--symbolic
			$target
			$directory
		]
	}

	return
}

export def "main" [
	--install-directory: path = "~/.local/share/",
	--bin-directory: path = "~/.local/bin/",
	--applications-directory: path = "~/.local/share/applications/",
]: nothing -> nothing {
	let install_directory = $install_directory | path expand
    let bin_directory = $bin_directory | path expand
    let applications_directory = $applications_directory | path expand

	# Some commands use $env.PWD to set relative paths.
	cd ($env.CURRENT_FILE | path dirname)

	# Install git hooks
	install git hooks

	# Create symlinks for the dotfiles
	let dotfiles = [
		"bashrc"
		"profile"
		"vim"
		"vimrc"
		"gvimrc"
		"gitconfig"
		"gitignore_global"
		"inputrc"
		"npmrc"
	]
	$dotfiles | each {|it|
		if ($env.HOME | path join $".($it)" | path type) == "symlink" {
			log info $"Symlink to dotfile already exists: .($it)"
		} else {
			if ($env.HOME | path join $".($it)" | path type) == "file" {
				mv ($env.HOME | path join $".($it)") ($env.HOME | path join $".($it).orig")
			}
			(install symlink
				--directory $env.HOME
				--target ([$env.PWD $it] | path join)
				--name $".($it)"
			)
		}
	}

	return
}

