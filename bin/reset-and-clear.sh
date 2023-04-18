#!/bin/sh

# https://gist.github.com/avindra/dd2c6f14ec6e03b05261d370ef60c9d8
# This script will reset the terminal in case it becomes unusable.

if [ -z "${ALACRITTY_LOG}" ]; then exit 1; fi

PID_LOG="${ALACRITTY_LOG##*-}"
TERM_PID="${PID_LOG%%.*}"

# FIXME: PPID of Alacritty on macOS is 1. This will not work.
# shellcheck disable=SC2039
if [[ "$(uname -s)" != 'Darwin' ]]
then
	tty=$(ps o tty= --ppid "${TERM_PID}")
	echo -e "\ec" > /dev/$tty
fi
