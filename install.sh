#!/usr/bin/env bash

##
## Install the profile
##

# TODO: Windows install
# See this about creating symlinks in Windows: https://www.joshkel.com/2018/01/18/symlinks-in-windows/
# May need to turn on developer mode in Windows.
# To install on Windows:
#   export MSYS=winsymlinks:nativestrict
#   cd ~
#   ln -s projects/dotfiles/bashrc .bashrc
#   ln -s projects/dotfiles/vimrc .vimrc
#   ln -s projects/dotfiles/gitconfig .gitconfig
#   ln -s projects/dotfiles/gitignore_global .gitignore_global

# base_dir is the base directory for the dotfiles repo, usually in ~/projects
base_dir="projects/dotfiles"

dotfiles=(
	bashrc
	profile
	vim
	vimrc
	gvimrc
	gitconfig
	gitignore_global
	inputrc
	npmrc
)

# Get the directory the script is located in.
if [[ ! "$(declare -p BASH_SOURCE)" =~ "declare -a" ]] && [[ -z "${BASH_SOURCE[0]}" ]]; then
	# This most likely happens when run inside a container from the host.
	DIR="$(dirname "$(dirname "$0")")"
else
	if [[ "$OSTYPE" == darwin* ]]; then
		# Mac's readline does not have --canonicalize argument
		# http://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
		DIR="$(dirname "$(grealpath "${BASH_SOURCE[0]}")")"
	elif [[ "$OSTYPE" == freebsd* ]]; then
		# FreeBSD doesn't have readline
		DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
	else
		#DIR="$( dirname "$( readlink --canonicalize "${BASH_SOURCE[0]}" )" )"
		#DIR="$( dirname "$( readlink "${BASH_SOURCE[0]}" )" )"
		DIR="$(dirname "${BASH_SOURCE[0]}")"
	fi
fi

# Add the git-hook
# User may not have permission to read .git/hooks
if [[ -d "${DIR}/.git/hooks" ]]; then
	[[ ! -e "${DIR}/.git/hooks/post-merge" ]] && ln -s "../../git-hooks/post-merge" "${DIR}/.git/hooks/post-merge"
fi

if [[ -z "$HOME" ]]; then
	# Run using bash -c
	echo "Home is not defined: ${HOME}"
	# This could happen if running the install from systemd-run outside the machine.
	HOME="/root"
fi

for file in ${dotfiles[*]}; do
	# root doesn't get .profile
	[[ $EUID -eq 0 ]] && [[ "${file}" == "profile" ]] && continue
	[[ ! -L "${HOME}/.${file}" ]] && [[ -f "${HOME}/.${file}" ]] && mv "${HOME}/.${file}" "${HOME}/.${file}.orig"

	# .vim is a directory
	[[ ! -L "${HOME}/.${file}" ]] && [[ -d "${HOME}/.${file}" ]] && mv "${HOME}/.${file}" "${HOME}/.${file}.orig"

	# Recreate the symbolic links
	[[ -L "${HOME}/.${file}" ]] && rm "${HOME}/.${file}"
	ln -s "./${base_dir}/${file}" "${HOME}/.${file}"
done

# Process ~/.cargo
config_dir="cargo"

# Cargo config in ~/.cargo/config
file="config"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
[[ ! -L "${config_file}" ]] && [[ -f "${config_file}" ]] && mv "${config_file}" "${config_file}.orig"
ln -s "${config_link}" "${config_file}"

# Process ~/.config
config_dir="config"

# Starship config in ~/.config/starship.toml
file="starship.toml"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Yamllint config in ~/.config/yamllint/config
file="config"
config_dir="config/yamllint"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}.yml"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Lapce config in ~/.config/lapce-stable/settings.toml
file="settings.toml"
config_dir="config/lapce-stable"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Helix config in ~/.config/helix/config.toml
file="config.toml"
config_dir="config/helix"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Helix runtime in ~/.config/helix/runtime/
file="runtime"
config_dir="config/helix"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Nushell config.nu in ~/.config/nushell/
file="config.nu"
config_dir="config/nushell"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Nushell env.nu in ~/.config/nushell/
file="env.nu"
config_dir="config/nushell"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Alacritty config in ~/.config/alacritty/alacritty.yml
os="unknown"
[[ $(uname -s) = 'Darwin' ]] && os="mac"
[[ $(uname -s) = 'FreeBSD' ]] && os="bsd"
[[ $(uname -s) = 'Linux' ]] && os="linux"
file_os="alacritty-${os}.yml"
file="alacritty.yml"
config_dir="config/alacritty"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file_os}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -L "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Alacritty themes are referenced in the config but not checked out automatically.
# Default theme is used if this doesn't exist.
if [[ ! -e "${HOME}/projects/github/alacritty-theme" ]]; then
	echo "Alacritty themes are not checked out automatically."
	echo mkdir --parents ~/projects/github/
	echo git clone https://github.com/alacritty/alacritty-theme ~/projects/github/alacritty-theme
fi

# Alacritty terminfo
if ! infocmp alacritty >/dev/null 2>&1; then
	# Need to compile the terminfo database
	if type -P tic >/dev/null 2>&1; then
		# It seems infocmp does not list $HOME/.terminfo as a known directory when run as root
		# If tic can't write to /usr/share/terminfo, it will default to $HOME/.terminfo
		tic -s -x -e alacritty,alacritty-direct ~/projects/dotfiles/local/share/alacritty/alacritty.info
		# umask might make the file unreadable for regular users (o-r)
		[[ -f "/usr/share/terminfo/a/alacritty" ]] && chmod go+r /usr/share/terminfo/a/alacritty*
	else
		echo "tic is not installed. Please install ncurses-devel and run install.sh again."
	fi
fi
