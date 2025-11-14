#!/usr/bin/env nu

# Get default install directory
def nvm_default_install_dir [] {
    if 'XDG_CONFIG_HOME' in $env {
        $env.XDG_CONFIG_HOME | path join "nvm"
    } else {
        $env.HOME | path join ".nvm"
    }
}

# Get install directory
def nvm_install_dir []: nothing -> string {
    if "NVM_DIR" in $env {
        $env.NVM_DIR
    } else {
        nvm_default_install_dir
    }
}

# Install NVM as script
def install_nvm_as_script [] {
	use std log

    let install_dir = (nvm_install_dir)
    if ($install_dir | path join "nvm.sh" | path exists) {
        log info $"=> nvm is already installed in ($install_dir)"
		return
	}
    mkdir $install_dir

	let url = (
		{
			scheme: https
			host: raw.githubusercontent.com
			path: ($env.NVM_REPO | path join 'refs/tags' $env.NVM_VERSION)
		} | url join
	)
	log info $"=> Downloading nvm as script to '($install_dir)'"

	# Download nvm.sh
    try {
		let file = 'nvm.sh'
        http get ($url | path join $file) | save ($install_dir | path join $file)
		chmod +x ($install_dir | path join $file)
    } catch {
        log error $"Failed to download '($url | path join 'nvm.sh')'"
        return 1
    }

    # Download nvm-exec
    try {
		let file = 'nvm-exec'
        http get ($url | path join $file) | save ($install_dir | path join $file)
		chmod +x ($install_dir | path join $file)
    } catch {
        log error $"Failed to download '($url | path join 'nvm-exec')'"
        return 2
    }

    # Download bash_completion
    try {
		let file = 'bash_completion'
        http get ($url | path join $file) | save ($install_dir | path join 'bash_completion')
    } catch {
        log error $"Failed to download '($url | path join 'bash_completion')'"
        return 2
    }
}

# Main installation function
def nvm_do_install [
	nvm_dir: string				# Directory to install nvm
] {
	use std log
	let nvm_dir = $env.NVM_DIR? | default ""

	if ($nvm_dir | is-not-empty) and not ($nvm_dir | path exists) {
		if ($nvm_dir | path type) == "file" {
			log error $"File '($nvm_dir)' has the same name as installation directory."
			exit 1
		}

		if $nvm_dir == (nvm_default_install_dir) {
			mkdir $nvm_dir
		} else {
			log error $"You have $NVM_DIR set to '($nvm_dir)', but that directory does not exist. Check your profile files and environment."
			exit 1
		}
	}

	# Install NVM using script method
	install_nvm_as_script

	# let install_dir = nvm_install_dir
	# let profile_install_dir = $install_dir | str replace $env.HOME "$HOME"

	# let source_str = $"\nexport NVM_DIR=\"($profile_install_dir)\"\n[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"  # This loads nvm\n"
	# let completion_str = "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion\n"

	# mut bash_or_zsh = false

	# log info "=> Append the following lines to your profile:"
	# print $source_str
	# log info ""

	# Source nvm (would need to be done in the shell)
	# source ($"(nvm_install_dir)/nvm.sh")

	# log info "=> Close and reopen your terminal to start using nvm or run the following to use it now:"
	# print $source_str
	# if $bash_or_zsh {
	# 	print $completion_str
	# }
}

# NVM (Node Version Manager) install script
# This script is based on https://github.com/nvm-sh/nvm/raw/refs/tags/v0.40.3/install.sh
def main [] {
	use std log
	$env.NVM_VERSION = 'v0.40.3'
	$env.NVM_REPO = 'nvm-sh/nvm'
	# TODO: Make the version dynamic.
	$env.NODE_VERSION = '20'
	nvm_do_install (nvm_install_dir)

	# Install Node.js
	^bash -c $"PROFILE=/dev/null source ~/.nvm/nvm.sh && nvm install ($env.NODE_VERSION)"
}