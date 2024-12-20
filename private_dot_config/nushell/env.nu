# Nushell Environment Config File
# https://github.com/nushell/nushell/blob/main/crates/nu-utils/src/sample_config/default_env.nu
#
# version = "0.99.2"

def create_left_prompt [] {
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

	let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
	let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
	# create a right prompt in magenta with green separators and am/pm underlined
	let time_segment = ([
		(ansi reset)
		(ansi magenta)
		(date now | format date '%Y-%m-%d %H:%M:%S')
	] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
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

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

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
    ($nu.data-dir | path join 'completions') # default home for nushell completions

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
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
	# FIXME: This default is not implemented in rust code as of 2023-09-06.
	($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# Add SSH agent
# https://www.nushell.sh/cookbook/ssh_agent.html#workarounds
# Run manually: ssh-agent -a ($env.XDG_RUNTIME_DIR | path join "ssh-agent.socket")
# In each terminal: $env.SSH_AUTH_SOCK = ($env.XDG_RUNTIME_DIR | path join "ssh-agent.socket")
# TODO: Add ssh-agent as a service.
do --env {
    let ssh_agent_file = (
        $nu.temp-path | path join $"ssh-agent-($env.USER? | default $env.USERNAME?).nuon"
    )

    if ($ssh_agent_file | path exists) {
        let ssh_agent_env = open ($ssh_agent_file)
        if (ps | where pid == ($ssh_agent_env.SSH_AGENT_PID | into int) | length) > 0 {
            load-env $ssh_agent_env
            return
        } else {
            rm $ssh_agent_file
        }
    }

    let ssh_agent_env = ^ssh-agent -c
        | lines
        | first 2
        | parse "setenv {name} {value};"
        | transpose --header-row
        | into record
    load-env $ssh_agent_env
    $ssh_agent_env | save --force $ssh_agent_file
}

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"
$env.PATH = ($env.PATH | split row (char esep))
# path add ($env.CARGO_HOME | path join "bin")
path add ($env.HOME | path join ".local" "bin")
path add ($env.HOME | path join "projects" "dotfiles" "bin")
path add "/usr/local/bin"
$env.PATH = ($env.PATH | uniq)

# Less options
# Discord: https://discord.com/channels/601130461678272522/601130461678272524/1178387079449808967
# The -X flag prevents faux scrolling (a.k.a. scrolling with the mouse)
# https://github.com/alacritty/alacritty/issues/2576#issuecomment-1375529269
$env.LESS = "--quit-if-one-screen --RAW-CONTROL-CHARS --chop-long-lines --search-skip-screen --ignore-case --LONG-PROMPT --jump-target=5"

# Use ripgrep config
$env.RIPGREP_CONFIG_PATH = $"($env.HOME)/.ripgreprc"
