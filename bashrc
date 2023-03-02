# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

# Check if this file has already been sourced
#[[ "true" == "${BASHRCREAD}" ]] && return

# Verbose logging
VERBOSE=false

# Process global bashrc
[[ -f /etc/bashrc ]] && source /etc/bashrc
[[ -f /etc/bash.bashrc ]] && source /etc/bash.bashrc

# Process scripts in ~/projects/dotfiles/bash.d/
if [[ "$OSTYPE" == darwin* ]]
then
	# Mac's readline does not have --canonicalize argument
	# http://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
	DIR="$( dirname "$( /opt/homebrew/opt/coreutils/bin/grealpath "${BASH_SOURCE[0]}" )" )"
elif [[ "$OSTYPE" == freebsd* ]]
then
	# FreeBSD doesn't have readline
	DIR="$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )"
else
	DIR="$( dirname "$( readlink --canonicalize "${BASH_SOURCE[0]}" )" )"
fi


######################################################################
# 80-path.sh
######################################################################

# https://www.cyberciti.biz/faq/redhat-linux-pathmunge-command-in-shell-script/
pathmunge () {
	[[ ! -d "${1}" ]] && return
	if ! echo "${PATH}" | grep -Eq "(^|:)${1}($|:)" ; then
		# Mac id does not accept long arguments
		# Linux id accepts short arguments
		if [[ "0" == "$(id -u)" ]] ; then
			# root always appends the path
			PATH="${PATH}:${1}"
		elif [[ "after" == "${2}" ]] ; then
			PATH="${PATH}:${1}"
		elif [[ "before" == "${2}" ]] ; then
			PATH="${1}:${PATH}"
		else
			# Add path to the end by default
			PATH="${PATH}:${1}"
		fi
	fi
}

# Add /*/sbin to the path
pathmunge "/sbin"
pathmunge "/usr/sbin"

# Custom programs on M1 Macs
pathmunge "/usr/local/bin"

# Custom install for Go binaries
#pathmunge "/opt/niceguyit/bin"

# Local binaries
pathmunge "${HOME}/bin"

# Go
pathmunge "${HOME}/go/bin"

# Rust
pathmunge "${HOME}/.cargo/bin"

# Python
pathmunge "${HOME}/.pyenv/bin"
# "pip install --user" installs to ~/.local/bin/
pathmunge "${HOME}/.local/bin"

# Flutter
pathmunge "${HOME}/projects/github/flutter/bin"

# Rancher Desktop
#[[ -d "${HOME}/.rd/bin" ]] && pathmunge "${HOME}/.rd/bin"
pathmunge "${HOME}/.rd/bin"

# Local git repos
pathmunge "${HOME}/projects/server-profile/bin"
pathmunge "${HOME}/projects/server-utils/bin"
pathmunge "${HOME}/projects/dotfiles/bin"

# Composer
pathmunge "${HOME}/.composer/vendor/bin"

# Java
pathmunge "${HOME}/local/spring-2.2.4.RELEASE/bin"

# Yarn
pathmunge "${HOME}/.yarn/bin"

# Current directory
pathmunge "."

# JetBrains Toolbox App
pathmunge "${HOME}/.local/share/JetBrains/Toolbox/scripts"



######################################################################
# mac-osx.sh
# Mac OSX specific
######################################################################
if [[ $(uname -s) = 'Darwin' ]]
then

	# M1 MacOS
	pathmunge "/opt/homebrew/bin" before

	# Prefer Homebrew packages over system installed packages.
	# coreutils
	# All commands have been installed with the prefix 'g'.
	# If you really need to use these commands with their normal names, you
	# can add a "gnubin" directory to your PATH from your bashrc
	pathmunge "$(brew --prefix)/opt/coreutils/libexec/gnubin" before
	# python
	#pathmunge "$(brew --prefix)/opt/python/libexec/bin" before
	# openjdk
	#pathmunge "$(brew --prefix)/opt/openjdk@11/bin" before
	# curl
	# brew installed curl but it doesn't have as many features enabled.
	# osx Features: AsynchDNS IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL libz HTTP2 UnixSockets HTTPS-proxy
	# brew Features: AsynchDNS IPv6 Largefile NTLM NTLM_WB SSL libz UnixSockets
	#pathmunge "$(brew --prefix)/opt/curl/bin" before

	# openssl
	# This formula is keg-only, which means it was not symlinked into /usr/local,
	# because Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries.
	# If you need to have this software first in your PATH run:
	#pathmunge "$(brew --prefix)/opt/openssl/bin" before

	# For compilers to find openssl you may need to set:
	#export LDFLAGS="-L$(brew --prefix)/opt/openssl/lib"
	#export CPPFLAGS="-I$(brew --prefix)/opt/openssl/include"

	# For pkg-config to find openssl you may need to set:
	#export PKG_CONFIG_PATH="$(brew --prefix)/opt/openssl/lib/pkgconfig"

	#Additionally, you can access their man pages with normal names if you add
	#the "gnuman" directory to your MANPATH from your bashrc as well:
	#
	MANPATH="$(brew --prefix)/opt/coreutils/libexec/gnuman:$MANPATH"

	# Bash completion has been installed to:
	#  /usr/local/etc/bash_completion.d
	if [ -d "$(brew --prefix)/etc/bash_completion.d" ]; then
		source "$(brew --prefix)"/etc/bash_completion.d/*
	fi
	# bash completion is in profile.d/bash_completion.sh
	if [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
		source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
	fi

	# Required for gupdatedb
	# 2021-09-17 Disabled to support mutli-byte chars
	#export LC_ALL="C"
fi


######################################################################
# 90-node.sh
######################################################################
# Node Version Manager
# Check if NVM is installed
if [[ -s "${HOME}/.nvm/nvm.sh" ]]
then
	export NVM_DIR="${HOME}/.nvm"

	# Make a symlink to the current version
	export NVM_SYMLINK_CURRENT=true

	# Load nvm
	[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"

	# Load nvm bash_completion
	[[ -s "${NVM_DIR}/bash_completion" ]] && \. "${NVM_DIR}/bash_completion"

	# 2022-08-01 - nvm was added twice to the path.
	#if [[ -s "${NVM_DIR}/current" ]]
	#then
	#	pathmunge "${NVM_DIR}/current/bin"
	#else
	#	pathmunge "${NVM_DIR}/bin"
	#fi
fi


################################################################################
# Ruby Version Manager (rvm)
################################################################################
# rvm adds $HOME/.rvm/bin to the path even though it's already there
if [[ -s "${HOME}/.rvm/scripts/rvm" ]]
then
	[[ -d "${HOME}/.rvm/bin" ]] && pathmunge "${HOME}/.rvm/bin"
	[[ -f "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
fi


######################################################################
# Go language support
######################################################################
if type -P go >/dev/null 2>&1
then

	# openSUSE uses /etc/profile.d/go.sh to setup the environment
	# 20190825: This might have changed sometime around go1.12 and/or openSUSE 15.1
	pathmunge "$(go env GOPATH)/bin"

	# Mac
	# libexec needs to be included because Go expects to find src in $GOROOT/src/
	pathmunge "$(go env GOROOT)"

	# FreeNAS
	[[ -d "/usr/local/go" ]] && export GOROOT="/usr/local/go"

	# Private repos
	# https://stackoverflow.com/questions/27500861/whats-the-proper-way-to-go-get-a-private-repository
	export GOPRIVATE="*.niceguyit.biz"

	# Disable telemetry
	export GOTELEMETRY=off

fi


######################################################################
# 99-python.sh
######################################################################
# Python support
# https://stackoverflow.com/questions/38112756/how-do-i-access-packages-installed-by-pip-user
#export PYTHONPATH="$(python -c "import site, os; print(os.path.join(site.USER_BASE, 'lib', 'python', 'site-packages'))"):$PYTHONPATH"

# Python Virtualenv
if type -P pyenv >/dev/null 2>&1
then
    #export PYENV_ROOT="$HOME/.pyenv"
    eval "$(pyenv init -)"
fi


######################################################################
# 99-ruby.sh
######################################################################
#[[ -d "${HOME}/.gem/bin" ]] && export PATH="${PATH}:${HOME}/.gem/bin"
## gem install directory
#export GEM_HOME="${HOME}/.gem"
#
## Include gem in path
#if which ruby >/dev/null 2>&1 && which gem >/dev/null 2>&1;
#then
#
#	if [[ -d "$(ruby -rrubygems -e 'puts Gem.user_dir')" ]]
#	then
#		# rvm wants .gem to be frist
#		export PATH="$(ruby -rrubygems -e 'puts Gem.user_dir'):${PATH}"
#	fi
#fi


######################################################################
# alias.sh
######################################################################
# ls
alias l='ls -lFh'
alias la='ls -lFah'
alias lt='ls -lFAhrt'
alias lrt='ls -lFAht'

# FreeBSD doesn't have vim
[[ $(uname -s) = 'FreeBSD' ]] && alias vim='vi'

# Display the path nicely
# TODO: This conflicts with /etc/bash.bashrc on openSUSE 15.0
# Need to check if the alias/function already exists before adding it.
alias ppath="echo \$PATH | tr ':' '\n'"

# Convert UNICODE (16-bit) to regular text (8-bit)
alias recode='recode -v UNICODE..UTF-8'

# Shortcut for chmod
alias x='chmod a+x'

# Alias for xfreerdp
alias rdp="xfreerdp /w:1920 /h:1080 +bitmap-cache +offscreen-cache /compression-level:2 /network:lan"

# fd all files and rg all files
alias fda="fd --no-ignore --hidden"
alias rga="rg --no-ignore --hidden"


######################################################################
# bash.sh
######################################################################

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
#export HISTFILESIZE=
#export HISTSIZE=
#export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
#export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
#PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Assign some BASH specific variables.
if [[ -n $BASH_VERSION ]]
then
	# append to the history file, don't overwrite it
	shopt -s histappend

	# check the window size after each command and, if necessary,
	# update the values of LINES and COLUMNS.
	#shopt -s checkwinsize

	# Use case sensitive matching for filename expansions (globs).
	#shopt -s nocaseglob

	# If no files are matched, the NULL string is returned.
	#shopt -s nullglob

	# History filename
	#export HISTFILE=~/history.txt

	# Bash 4.3 and later use -1 to set unlimited history.
	# Bash prior to 4.3 use "" to set unlimited history.
	if [[ "4.3.0" == $(echo -e "$BASH_VERSION\n4.3.0" | sort --version-sort | head -1) ]]
	then
		# The maximum number of commands to remember on the history list.
		export HISTSIZE=-1

		# The maximum number of lines contained in the history file.
		export HISTFILESIZE=-1

		# Change the file location because certain bash sessions truncate .bash_history file upon close.
		# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
		export HISTFILE=~/.bash_eternal_history

		# Force prompt to write history after every command.
		# http://superuser.com/questions/20900/bash-history-loss
		PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

	else
		# The maximum number of commands to remember on the history list.
		export HISTSIZE=

		# The maximum number of lines contained in the history file.
		export HISTFILESIZE=

		# Change the file location because certain bash sessions truncate .bash_history file upon close.
		# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
		export HISTFILE=~/.bash_eternal_history

		# Force prompt to write history after every command.
		# http://superuser.com/questions/20900/bash-history-loss
		PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

	fi

	# "ignoredups" means to not enter lines which match the last entered line.
	# don't put duplicate lines in the history. See bash(1) for more options
	# https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
	export HISTCONTROL="ignoredups:erasedups"

	# Taken from http://www.jmglov.net/unix/bash.html
	# Don't keep useless history commands. Note the last pattern is to not
	# keep dangerous commands in the history file.  Who really needs to
	# repeat the shutdown(8) command accidentally from your command
	# history?
	# A colon-separated list of patterns used to decide which command lines should be
	# saved on the history list.
	export HISTIGNORE='\&:fg:bg:ls:l:ll:lt:lrt:lsd:pwd:cd ..:cd ~-:cd -:cd:jobs::x:which*'

	# The maximum number of history events to save in the history file. (disk)
	export SAVEHIST=5000000
fi


######################################################################
# env.sh
######################################################################
#
# Environmental variables
# See http://teaching.idallen.com/net2003/06w/notes/character_sets.txt
#
# 2021-09-17 Try to use multi-byte characters
# From /etc/sysconfig/language
# > Local users will get RC_LANG as their default language, i.e. the
# > environment variable $LANG . $LANG is the default of all $LC_*-variables,
# > as long as $LC_ALL is not set, which overrides all $LC_-variables.
if [[ $(uname -s) = 'FreeBSD' ]]
then
	# Don't change FreeNAS locale
	true
else

	# Mac and Linux
	# Show unicode by processing multi-byte chars
	[[ ! "$LANG" ]]			&& export LANG="en_US.UTF-8"

	# collate in strict numeric order
	# Separate [a-z] from [A-Z] so sorting is intuitive
	export LC_COLLATE="C"

	[[ ! "$LC_CTYPE" ]]				&& export LC_CTYPE="en_US.UTF-8"
	[[ ! "$LC_NUMERIC" ]]			&& export LC_NUMERIC="en_US.UTF-8"
	[[ ! "$LC_TIME" ]]				&& export LC_TIME="en_US.UTF-8"
	[[ ! "$LC_MONETARY" ]]			&& export LC_MONETARY="en_US.UTF-8"
	[[ ! "$LC_MESSAGES" ]]			&& export LC_MESSAGES="en_US.UTF-8"
	[[ ! "$LC_PAPER" ]]				&& export LC_PAPER="en_US.UTF-8"
	[[ ! "$LC_NAME" ]]				&& export LC_NAME="en_US.UTF-8"
	[[ ! "$LC_ADDRESS" ]]			&& export LC_ADDRESS="en_US.UTF-8"
	[[ ! "$LC_TELEPHONE" ]]			&& export LC_TELEPHONE="en_US.UTF-8"
	[[ ! "$LC_MEASUREMENT" ]]		&& export LC_MEASUREMENT="en_US.UTF-8"
	[[ ! "$LC_IDENTIFICATION" ]]	&& export LC_IDENTIFICATION="en_US.UTF-8"
fi

# FreeBSD/FreeNAS doesn't set the PAGER
[[ -z "$PAGER" ]] && export PAGER=less
export LESS="--ignore-case --RAW-CONTROL-CHARS --search-skip-screen --LONG-PROMPT --jump-target=5 --quit-if-one-screen"
#export LESSOPEN="|/usr/local/bin/lesspipe.sh %s"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
export SYSTEMD_PAGER=

# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
# FIXME: which is not installed in production
# TODO: type -P is a posix replacement
export EDITOR=$(type -P vim)
# export EDITOR=/usr/bin/vim

# Oracle's Java
# Required for Elasticsearch
#export JAVA_HOME=/usr/lib64/jvm/jre-openjdk/

# ls now defaults to adding single quotes around files with special characters.
# http://unix.stackexchange.com/questions/258679/why-is-ls-suddenly-wrapping-items-with-spaces-in-single-quotes
export QUOTING_STYLE=literal

# Disable dotnet telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export VCPKG_DISABLE_METRICS=true
[[ -f "${HOME}/projects/github/vcpkg/vcpkg" ]] && export VCPKG_ROOT="${HOME}/projects/github/vcpkg"

# SOPS Age support
[[ -f "${HOME}/.config/sops/age/keys.txt" ]] && export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt



if [[ $EUID -ne 0 ]] && tty >/dev/null
then
	# @see https://d.niceguyit.biz/en/internal/troubleshooting
	# 2018-01-01 - Add group write and other read permissions for Apache for WordPress-Network
	# 2022-01-13 - This was causing issues with zypper on openSUSE Leap 15.3. Disabled it.
	umask g-w,o-rwx
	# Disabling for now to prevent conflict with the above.
	# Unix on Windows doesn't set correct umask
	# @see https://github.com/Microsoft/BashOnWindows/issues/352
	#umask o-rwx
fi


######################################################################
# functions.sh
######################################################################
# Show the hostname with the full log path
function logpath() {
	echo "${HOSTNAME%%.*}:$(ls -1d "$(pwd -P)/$1")"
}

# Add the file sizes output from ls -l
function ad() {
	field=5
	[[ -n $1 ]] && field=$1
	gawk "{sum += \$$field} END {printf \"%'d\n\", sum}"
}

# List only directories
function lsd() {
	# -d is necessary to list directories
	ls -ldFA --color=always "$@" | grep '^[dl]'
}

# Show the count of matches
function grepc() {
	grep -c "$@" | grep -v ':0$'
}

# Swap two files/dirs
# https://stackoverflow.com/questions/1115904/shortest-way-to-swap-two-files-in-bash
function swap() {
	tmpfile=$(mktemp "$(dirname "$1")/XXXXXX")
	mv "$1" "$tmpfile" && mv "$2" "$1" &&  mv "$tmpfile" "$2"
}

# Short git commit
# Minus is not a valid identifier for shell functions.
# TODO: Should this be moved into a separate program?
function git_commit() {
	git add --update
	git commit --message "$1"
   	git push
}



######################################################################
# fzf.bash
######################################################################
# Setup fzf
# ---------

if [[ "$OSTYPE" == darwin* ]]
then
	if type -P fzf >/dev/null 2>&1
	then
		# Auto-completion
		# ---------------
		[[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.bash" 2> /dev/null

		# Key bindings
		# ------------
		source "$(brew --prefix)/opt/fzf/shell/key-bindings.bash"
	fi
else
	# Ctrl-R causes Perl to complain about the locale not being set. However it IS set.
	# This works: env LC_ALL=en_US.UTF-8 perl -e exit
	# This fails: env LC_ALL= perl -e exit
	#   perl: warning: Setting locale failed.
	#   perl: warning: Please check that your locale settings:
	#           LANGUAGE = "en_US.UTF-8",
	#           LC_ALL = "",
	#           LC_MEASUREMENT = "en_US.UTF-8",
	#           LC_MONETARY = "en_US.UTF-8",
	#           LC_COLLATE = "C",
	#           LC_NUMERIC = "en_US.UTF-8",
	#           LC_TIME = "en_SE.UTF-8",
	#           LANG = "en_US.UTF-8"
	#       are supported and installed on your system.
	#   perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
	# See https://perldoc.perl.org/perllocale#PERL_SKIP_LOCALE_INIT
	export PERL_SKIP_LOCALE_INIT=true

	# For some reason, /usr/share/bash-completion/bash_completion does not source
	# /usr/share/bash-completion/completions/fzf* so that Ctrl-R works.
	[[ -f "/usr/share/bash-completion/completions/fzf" ]] && source "/usr/share/bash-completion/completions/fzf"
	[[ -f "/usr/share/bash-completion/completions/fzf-key-bindings" ]] && source "/usr/share/bash-completion/completions/fzf-key-bindings"

	# Ubuntu
	[[ -f "/usr/share/doc/fzf/examples/completion.bash" ]] && source "/usr/share/doc/fzf/examples/completion.bash"
	[[ -f "/usr/share/doc/fzf/examples/key-bindings.bash" ]] && source "/usr/share/doc/fzf/examples/key-bindings.bash"

fi


######################################################################
# ls-colors.sh
######################################################################
##
## FreeNAS does not include LS_COLORS.
## This doesn't work, I suspect because FreeNAS ls doesn't support LS_COLORS.
##
if [[ `uname -s` = 'FreeBSD' ]]
then
	# FreeNAS commands don't support --color option
	# CLICOLOR=true enables the LSCOLORS option (not LS_COLORS)

	# Use ANSI color sequences to distinguish file types.  See LSCOLORS below.  In addition to the
	# file types mentioned in the -F option some extra attributes (setuid bit set, etc.) are also
	# displayed.  The colorization is dependent on a terminal type with the proper termcap(5)
	# capabilities.  The default cons25 console has the proper capabilities, but to
	# display the colors in an xterm(1), for example, the TERM variable must be set to xterm-color.
	# Other terminal types may require similar adjustments.  Colorization is silently disabled if
	# the output is not directed to a terminal unless the CLICOLOR_FORCE variable is defined.
	export CLICOLOR=true

	# The value of this variable describes what color to use for which
	# attribute when colors are enabled with CLICOLOR.  This string is a
	# concatenation of pairs of the format fb, where f is the foreground color and b
	# is the background color.
	#
	# The color designators are as follows:
	#
	#	a     black
	#	b     red
	#	c     green
	#	d     brown
	#	e     blue
	#	f     magenta
	#	g     cyan
	#	h     light grey
	#	A     bold black, usually shows up as dark grey
	#	B     bold red
	#	C     bold green
	#	D     bold brown, usually shows up as yellow
	#	E     bold blue
	#	F     bold magenta
	#	G     bold cyan
	#	H     bold light grey; looks like bright white
	#	x     default foreground or background
	#
	# Note that the above are standard ANSI colors.  The actual display may
	# differ depending on the color capabilities of the terminal in use.
	#
	# The order of the attributes are as follows:
	#
	#	1.   directory
	#	2.   symbolic link
	#	3.   socket
	#	4.   pipe
	#	5.   executable
	#	6.   block special
	#	7.   character special
	#	8.   executable with setuid bit set
	#	9.   executable with setgid bit set
	#	10.  directory writable to others, with sticky bit
	#	11.  directory writable to others, without sticky bit
	#
	# The default is "exfxcxdxbxegedabagacad", i.e., blue foreground and default
	# background for regular directories, black foreground and red background for
	# setuid executables, etc.
	export LSCOLORS="Gxfxcxdxdxegedabagacad"

else
	[[ "true" == "$VERBOSE" ]] && echo "Processing LSCOLORS for Linux/Mac"

	# which is not installed in production
	if [[ -x "/usr/bin/which" ]]
	then
		[[ "true" == "$VERBOSE" ]] && echo "Checking for dircolors"
		if type -P dircolors >/dev/null
		then
			[[ "true" == "$VERBOSE" ]] && echo "Executing dircolors"
			eval $(dircolors --bourne-shell)
		else
			[[ "true" == "$VERBOSE" ]] && echo "dircolors not found"
			[[ "true" == "$VERBOSE" ]] && echo "$PATH"
		fi
	fi

	# Enable color if available
	if [[ ! -z ${LS_COLORS+x} ]]
	then
		alias ls='ls --color=auto'
		alias dir='dir --color=auto'
		alias vdir='vdir --color=auto'

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi

fi


######################################################################
# starship
######################################################################
if type -P starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
else
    ######################################################################
    # prompt.sh if starship is not installed
    ######################################################################

    # ANSI colors
    # http://wiki.archlinux.org/index.php/Color_Bash_Prompt
    txtblk='\e[0;30m' # Black - Regular
    txtred='\e[0;31m' # Red
    txtgrn='\e[0;32m' # Green
    txtylw='\e[0;33m' # Yellow
    txtblu='\e[0;34m' # Blue
    txtpur='\e[0;35m' # Purple
    txtcyn='\e[0;36m' # Cyan
    txtwht='\e[0;37m' # White
    bldblk='\e[1;30m' # Black - Bold
    bldred='\e[1;31m' # Red
    bldgrn='\e[1;32m' # Green
    bldylw='\e[1;33m' # Yellow
    bldblu='\e[1;34m' # Blue
    bldpur='\e[1;35m' # Purple
    bldcyn='\e[1;36m' # Cyan
    bldwht='\e[1;37m' # White
    undblk='\e[4;30m' # Black - Underline
    undred='\e[4;31m' # Red
    undgrn='\e[4;32m' # Green
    undylw='\e[4;33m' # Yellow
    undblu='\e[4;34m' # Blue
    undpur='\e[4;35m' # Purple
    undcyn='\e[4;36m' # Cyan
    undwht='\e[4;37m' # White
    bakblk='\e[40m'   # Black - Background
    bakred='\e[41m'   # Red
    badgrn='\e[42m'   # Green
    bakylw='\e[43m'   # Yellow
    bakblu='\e[44m'   # Blue
    bakpur='\e[45m'   # Purple
    bakcyn='\e[46m'   # Cyan
    bakwht='\e[47m'   # White
    txtrst='\e[0m'    # Text Reset
    
    # Nice prompt
    UsernameColor="${bldgrn}"
    if [[ "$EUID" -eq 0 ]]
    then
        UsernameColor="${bldred}"
    fi
    PS1="${debian_chroot:+($debian_chroot)}\[${txtpur}\]\t\[${txtrst}\] \[${UsernameColor}\]\u\[${txtrst}\]@\[${txtgrn}\]\H\[${txtrst}\] \[${bldblu}\]\w\[${txtrst}\] # "
fi


######################################################################
# ripgrep.sh
######################################################################
# ripgrep supports configuration files. Set RIPGREP_CONFIG_PATH to a
# configuration file. The file can specify one shell argument per line. Lines
# starting with '#' are ignored. For more details, see the man page or the
# README.
export RIPGREP_CONFIG_PATH="${HOME}/projects/dotfiles/ripgreprc"


######################################################################
# ssh-agent.sh
######################################################################
# Use [Funtoo] Keychain to manage ssh-agent
if [[ $EUID -ne 0 ]] && tty >/dev/null
then
	# This is after the cleanup so that it will start a new agent if the last agent was deleted
	# The banner on STDERR is causing JetBrains Gateway to fail to deploy remote IDEs.
	# https://youtrack.jetbrains.com/issue/CWM-6796
	type -P keychain 1>/dev/null 2>&1 && eval $( keychain --eval --agents ssh 2>/dev/null )
fi


######################################################################
# termcap.sh
######################################################################
# See https://russellparker.me/2018/02/23/adding-colors-to-man/

# Default to sane TERM if alacritty terminfo hasn't been installed.
if [[ "${TERM}" == "alacritty" ]] && ! infocmp alacritty >/dev/null 2>&1
then
    export TERM=xterm-256color
fi

# The snap man page gets narrower as you page down. Disable this to make sure it's not
# interfering with the man page.
# I don't think this is causing the man page error.
# However, it is causing tput errors in containers.
if [[ "${TERM}" != "dumb" && "${TERM}" != "alacritty" ]]
then
	LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
	LESS_TERMCAP_md=$(tput bold; tput setaf 6)
	LESS_TERMCAP_me=$(tput sgr0)
	LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
	LESS_TERMCAP_se=$(tput rmso; tput sgr0)
	LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
	LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
	LESS_TERMCAP_mr=$(tput rev)
	LESS_TERMCAP_mh=$(tput dim)

	export MANROFFOPT='-c'
	export LESS_TERMCAP_mb
	export LESS_TERMCAP_md
	export LESS_TERMCAP_me
	export LESS_TERMCAP_so
	export LESS_TERMCAP_se
	export LESS_TERMCAP_us
	export LESS_TERMCAP_ue
	export LESS_TERMCAP_mr
	export LESS_TERMCAP_mh
fi


######################################################################
# Bash Completions
######################################################################
if compgen -G "${HOME}/projects/dotfiles/bash-completion/*" > /dev/null
then
	source ${HOME}/projects/dotfiles/bash-completion/*
fi

######################################################################
# Finish
######################################################################
# Prevent bashrc from being read twice
export BASHRCREAD=true
