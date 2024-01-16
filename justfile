# All arguments will be passed as positional arguments.
set positional-arguments
# Use Nushell for all shells
set shell := ['nu', '-c']
# The export setting causes all just variables to be exported as environment variables. Defaults to false.
set export

## These are environment variables for the tasks.

# SOPS_AGE_KEY_FILE is used by SOPS and points to the AGE key file
# age-genkey does not save the key. It needs to be explicitly saved in this location for SOPS to find it.
export SOPS_AGE_KEY_FILE := clean(join(env_var('HOME'), '.config/sops/age/keys.txt'))


# default recipe to display help information
default:
	@just --list


# list the just recipes
list:
	@just --list


# Require a command to be available
require-command command:
	#!/usr/bin/env nu
	if ("{{command}}" | str contains " ") {
		# Command to run
		do { {{command}} } | complete
		if ($env.LAST_EXIT_CODE == 0) {
			exit 0
		} else {
			print $"'{{command}}' did not exit cleanly. Please install '{{command}}' is available."
			exit 1
		}
	} else {
		if (which {{command}}| is-empty) {
			print $"'{{command}}' executable not found. Please install '{{command}}' and try again."
			exit 1
		}
	}


# Install the chezmoi config to the user's home directory.
chezmoi-install-config:
	#!/usr/bin/env nu

	# Get the users name and email from their ~/.gitconfig
	let git_config = ("~/.gitconfig" | path expand)
	mut user_name = ""
	mut user_email = ""
	print $"git_config: ($git_config)"
	if ($git_config | path exists) {
		# FIXME: Check if the nu_plugin_formats plugin is available before using 'from ini'
		$user_name = (open $git_config | from ini | get --ignore-errors user.name)
		$user_email = (open $git_config | from ini | get --ignore-errors user.email)
	}
	let chezmoi_dir = ("~/.config/chezmoi" | path expand)
	if not ($chezmoi_dir | path exists) {
		mkdir $chezmoi_dir
	}
	open chezmoi-example.jsonc
		| from json
		| update sourceDir ($env.HOME | path join "projects/dotfiles")
		| update data.git.name $user_name
		| update data.git.email $user_email
		| update data.firefox.profile_name $env.USER
		| to json
		| save ($chezmoi_dir | path join "chezmoi.jsonc")


# Get the SOPS_AGE_KEY_FILE environment variable.
sops-get-env:
	#!/usr/bin/env nu
	print $"$env.SOPS_AGE_KEY_FILE = ($env.SOPS_AGE_KEY_FILE)"


# Generate encryption keys for age
age-genkeys: (require-command "age-keygen")
	#!/usr/bin/env nu

	if (which age-keygen | is-empty) {
		print $"'age-keygen' executable not found. Please install 'age-keygen' and try again."
		exit 1
	}
	if ($env.SOPS_AGE_KEY_FILE | path exists) {
		print $"AGE key file '($env.SOPS_AGE_KEY_FILE)' exists."
		exit
	}
	print $"$env.SOPS_AGE_KEY_FILE = ($env.SOPS_AGE_KEY_FILE)"
	let age_dir = ($env.SOPS_AGE_KEY_FILE | path dirname)
	if not ($age_dir | path exists) {
		print $"Creating age_dir: '($age_dir)'"
		mkdir $age_dir
	}
	^age-keygen --output $env.SOPS_AGE_KEY_FILE


# Use sops to enccrypt an example file so that the encrypted file can be edited.
sops-encrypt-file prefix='cfg': (require-command "sops")
	#!/usr/bin/env nu

	cd "{{invocation_directory_native()}}"
	let ext = (glob {{prefix}}.example.sops.*
		| path basename
		| split column '.'
		| transpose
		| last 1
		| get column1.0)
	let encrypted_file = $"{{prefix}}.sops.($ext)"
	let example_file = $"{{prefix}}.example.sops.($ext)"
	if ($encrypted_file | path exists) {
		print $"Encrypted config file already exists: ($encrypted_file)"
		return
	}
	^sops --encrypt $example_file | save $encrypted_file
	print $"Created encrypted file '($encrypted_file)' from example file '($example_file)'"
