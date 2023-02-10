#!/usr/bin/env bash

##
## Install the profile
##

dotfiles=( \
	bashrc \
	profile \
	vim \
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
	[[ -h "${HOME}/.${file}" ]] && rm "${HOME}/.${file}"
	[[ -f "${HOME}/.${file}" ]] && mv "${HOME}/.${file}" "${HOME}/.${file}-orig"
	# Use relative links instead of absolute
	ln -s "./projects/dotfiles/${file}" "${HOME}/.${file}"
done


# Add starship config
[[ ! -d "${HOME}/.config" ]] && mkdir --parents "${HOME}/.config"
[[ -L "${HOME}/.config/starship.toml" ]] && rm "${HOME}/.config/starship.toml"
[[ ! -e "${HOME}/.config/starship.toml" ]] && ln -s ../projects/dotfiles/config/starship.toml "${HOME}/.config/starship.toml"
