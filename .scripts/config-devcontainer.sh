#!/usr/bin/env bash

# FIXME: It seems JetBrains does not run postCreateCommand as the user.
# https://containers.dev/implementors/json_reference/
# This is run as root.

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
  [[ ! -e /.jbdevcontainer/config/chezmoi ]] && ln -s ~/.config/chezmoi /.jbdevcontainer/config/
  [[ ! -e /.jbdevcontainer/data/chezmoi ]] && ln -s ~/.config/chezmoi /.jbdevcontainer/data/
  
  # Nushell uses $XDG_CONFIG_HOME for the config directory.
  [[ ! -e /.jbdevcontainer/config/nushell ]] && ln -s ~/.config/nushell /.jbdevcontainer/config/

fi
