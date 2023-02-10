# Sample .profile for SuSE Linux
# rewritten by Christian Steinruecken <cstein@suse.de>
#
# This file is read each time a login shell is started.
# All other interactive shells will only read .bashrc; this is particularly
# important for language settings, see below.

# Remove the compose key from the right control key
# This caused a blank screen on Leap 15.0
#[[ $DISPLAY ]] && [[ -x "$(which xmodmap 2>/dev/null)" ]] && xmodmap -verbose ~/.xmodmaprc

test -z "$PROFILEREAD" && . /etc/profile || true

# Set XAUTHORITY for KeePassXC
# This caused a blank screen on Leap 15.0
#export XAUTHORITY=${HOME}/.Xauthority

# https://askubuntu.com/questions/161249/bashrc-not-executed-when-opening-new-terminal
if [[ -n "$BASH_VERSION" ]]; then
	# include .bashrc if it exists
	if [[ -f "$HOME/.bashrc" && "true" != "${BASHRCREAD}" ]]; then
		. "$HOME/.bashrc"
	fi
fi
