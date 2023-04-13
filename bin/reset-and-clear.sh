#!/bin/sh

# https://gist.github.com/avindra/dd2c6f14ec6e03b05261d370ef60c9d8
# This script will reset the terminal in case it becomes unusable.

if [ -z "${ALACRITTY_LOG}" ]; then exit 1; fi

TERM_PID="${ALACRITTY_LOG//[^0-9]/}"
tty=$(ps o tty= --ppid $TERM_PID)

echo -e "\ec" > /dev/$tty
