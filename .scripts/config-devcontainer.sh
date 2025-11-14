#!/usr/bin/env bash

# FIXME: It seems JetBrains does not run postCreateCommand as the user.
# https://containers.dev/implementors/json_reference/
# This is run as root.

# Add the user to the host's docker group
sudoIf() { if [ "$(id -u)" -ne 0 ]; then sudo "$@"; else "$@"; fi }
NONROOT_USER=dev
SOCKET_GID=$(stat -c '%g' /var/run/docker.sock)
if [ "${SOCKET_GID}" != '0' ]; then
  if [ "$(grep :${SOCKET_GID}: /etc/group)" = '' ]; then
    sudoIf groupadd --gid ${SOCKET_GID} docker-host;
  fi

  if [ "$( id ${NONROOT_USER} | grep -E "groups=.*(=|,)${SOCKET_GID}\(" )" = '' ]; then
    sudoIf usermod --append --group ${SOCKET_GID} ${NONROOT_USER};
  fi
fi

# Install Prettier and cspell
[[ ! -e ".bun/bin/prettier" ]] && /usr/local/bin/bun install --global prettier
[[ ! -e ".bun/bin/cspell" ]] && /usr/local/bin/bun install --global cspell

# https://www.jetbrains.com/help/idea/dev-container-limitations.html#additional_limitations_remote_backend
# The following environment variables are used by the remote backend IDE and cannot be reassigned in the
# `devcontainer.json` configuration file:
#   XDG_CACHE_HOME
#   XDG_CONFIG_HOME
#   XDG_DATA_HOME
if [[ -d /.jbdevcontainer/ ]]
then

  # Chezmoi uses $XDG_CONFIG_HOME for the config directory and $XDG_DATA_HOME for the data directory.
  if [[ -d /.jbdevcontainer/config/ ]] && [[ ! -e /.jbdevcontainer/config/chezmoi ]]
  then
    ln -s ~/.config/chezmoi /.jbdevcontainer/config/
  fi
  if [[ -d /.jbdevcontainer/data/ ]] && [[ ! -e /.jbdevcontainer/data/chezmoi ]]
  then
    ln -s ~/.config/chezmoi /.jbdevcontainer/data/
  fi

  # Nushell uses $XDG_CONFIG_HOME for the config directory.
  if [[ -d /.jbdevcontainer/config/ ]] && [[ ! -e /.jbdevcontainer/config/nushell ]]
  then
    ln -s ~/.config/nushell /.jbdevcontainer/config/
  fi

fi
