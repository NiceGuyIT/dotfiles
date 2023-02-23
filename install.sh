#!/usr/bin/env bash

##
## Install the profile
##

# base_dir is the base directory for the dotfiles repo, usually in ~/projects
base_dir="projects/dotfiles"

dotfiles=( \
	bashrc \
	profile \
	vimrc \
	gvimrc \
	gitconfig \
	gitignore_global \
	npmrc \
)

# Get the directory the script is located in.
if [[ ! "$(declare -p BASH_SOURCE)" =~ "declare -a" ]] && [[ -z "$BASH_SOURCE" ]]
then
    # This most likely happens when run inside a container from the host.
    DIR="$( dirname "$(dirname "$0")" )"
else
    if [[ "$OSTYPE" == darwin* ]]
    then
        # Mac's readline does not have --canonicalize argument
        # http://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
        DIR="$( dirname "$( grealpath "${BASH_SOURCE[0]}" )" )"
    elif [[ "$OSTYPE" == freebsd* ]]
    then
        # FreeBSD doesn't have readline
        DIR="$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )"
    else
        #DIR="$( dirname "$( readlink --canonicalize "${BASH_SOURCE[0]}" )" )"
        #DIR="$( dirname "$( readlink "${BASH_SOURCE[0]}" )" )"
        DIR="$( dirname "${BASH_SOURCE[0]}" )"
    fi
fi

# Add the git-hook
if [[ ! -d "${DIR}/.git/hooks" ]]
then
    echo "git hooks directory does not exist: ${DIR}/.git/hooks"
    exit 1
fi
[[ ! -e "${DIR}/.git/hooks/post-merge" ]] && ln -s "../../git-hooks/post-merge" "${DIR}/.git/hooks/post-merge"


if [[ -z "$HOME" ]]
then
    # Run using bash -c
    echo "Home is not defined: ${HOME}"
    # This could happen if running the install from systemd-run outside the machine.
    HOME="/root"
fi

for file in ${dotfiles[*]}
do
	# root doesn't get .profile
	[[ $EUID -eq 0 ]] && [[ "${file}" == "profile" ]] && continue
	[[ ! -h "${HOME}/.${file}" ]] && [[ -f "${HOME}/.${file}" ]] && mv "${HOME}/.${file}" "${HOME}/.${file}.orig"

	# Recreate the symbolic links
	[[ -h "${HOME}/.${file}" ]] && rm "${HOME}/.${file}"
   	ln -s "./${base_dir}/${file}" "${HOME}/.${file}"
done

# ~/.vim is a directory with symbolic links inside
file="pack"
config_dir="vim"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../${base_dir}/${config_dir}/${file}"
[[ -h "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

file="spell"
config_dir="vim"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../${base_dir}/${config_dir}/${file}"
[[ -h "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Process ~/.config
config_dir="config"

# Starship config in ~/.config/starship.toml
file="starship.toml"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -h "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Alacritty config in ~/.config/alacritty/alacritty.yml
file="alacritty.yml"
config_dir="config/alacritty"
config_file="${HOME}/.${config_dir}/${file}"
config_link="../../${base_dir}/${config_dir}/${file}"
[[ ! -d "${HOME}/.${config_dir}" ]] && mkdir --parents "${HOME}/.${config_dir}"
[[ -h "${config_file}" ]] && rm "${config_file}"
ln -s "${config_link}" "${config_file}"

# Alacritty themes are referenced in the config but not checked out automatically.
# Default theme is used if this doesn't exist.
if [[ ! -e "${HOME}/projects/github/alacritty-theme" ]]
then
	echo "Alacritty themes are not checked out automatically."
	echo mkdir --parents ~/projects/github/
	echo git clone https://github.com/alacritty/alacritty-theme ~/projects/github/alacritty-theme
fi
