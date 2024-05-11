# Nushell Environment Config File
#
# version = "0.85.0"

def create_left_prompt [] {
	let home =  $nu.home-path

	let dir = ([
		($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
		($env.PWD | str substring ($home | str length)..)
	] | str join)

	let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
	let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
	let path_segment = $"($path_color)($dir)"

	$path_segment | str replace --all (char path_sep) $"($separator_color)/($path_color)"
}

def create_right_prompt [] {
	# create a right prompt in magenta with green separators and am/pm underlined
	let time_segment = ([
		(ansi reset)
		(ansi magenta)
		(date now | format date '%Y-%m-%d %H:%M:%S') # try to respect user's locale
	] | str join | str replace --regex --all "([/:-])" $"(ansi green)${1}(ansi magenta)" |
		str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

	let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
		(ansi rb)
		($env.LAST_EXIT_CODE)
	] | str join)
	} else { "" }

	([$last_exit_code, (char space), $time_segment] | str join)
}

# Note: PROMPT_COMMAND and PROMPT_COMMAND_RIGHT are overwritten by the Starship config.
# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "# " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "# " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# https://www.nushell.sh/book/3rdpartyprompts.html#starship
#if not (which starship | is-empty) {
#	# Starship is installed
#	$env.STARSHIP_SHELL = "nu"
#}

const STARSHIP_CACHE = ("~/.cache/starship" | path expand)
# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
	# FIXME: This default is not implemented in rust code as of 2023-09-06.
	($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts

	# Modules
	($nu.default-config-dir | path join 'modules')

	# Add $STARSHIP_CACHE directory to search for 'use' scripts
	$STARSHIP_CACHE
]

# https://starship.rs/guide/#step-2-set-up-your-shell-to-use-starship
if not (which starship | is-empty) {
	# Starship is installed
	mkdir $STARSHIP_CACHE
	# FIXME: Nu does not have the concept of umask. Need to set the permissions explicitly
	chmod g-w,o-rwx $STARSHIP_CACHE
	if (($STARSHIP_CACHE | path join "starship.nu") | is-empty) {
		# Create new config only if it doesn't exist.
		starship init nu | save ($STARSHIP_CACHE | path join "starship.nu")
	}
}

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
	# FIXME: This default is not implemented in rust code as of 2023-09-06.
	($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# Add SSH agent
# https://www.nushell.sh/cookbook/ssh_agent.html#workarounds
# Run manually: ssh-agent -a ($env.XDG_RUNTIME_DIR | path join "ssh-agent.socket")
# In each terminal: $env.SSH_AUTH_SOCK = ($env.XDG_RUNTIME_DIR | path join "ssh-agent.socket")
# TODO: Add ssh-agent as a service.
let sshAgentFilePath = $"/tmp/ssh-agent-($env.USER).nuon"
if ($sshAgentFilePath | path exists) and ($"/proc/((open $sshAgentFilePath).SSH_AGENT_PID)" | path exists) {
	# loading it
	load-env (open $sshAgentFilePath)
} else {
	# creating it
	^ssh-agent -c
		| lines
		| first 2
		| parse "setenv {name} {value};"
		| transpose -r
		| into record
		| save --force $sshAgentFilePath
	load-env (open $sshAgentFilePath)
}

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
$env.PATH = ($env.PATH | split row (char esep) | append ($env.HOME | path join 'projects/dotfiles/bin'))

# Less options
# Discord: https://discord.com/channels/601130461678272522/601130461678272524/1178387079449808967
# The -X flag prevents faux scrolling (a.k.a. scrolling with the mouse)
# https://github.com/alacritty/alacritty/issues/2576#issuecomment-1375529269
$env.LESS = "--quit-if-one-screen --RAW-CONTROL-CHARS --chop-long-lines --search-skip-screen --ignore-case --LONG-PROMPT --jump-target=5"
