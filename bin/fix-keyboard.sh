#!/usr/bin/env bash

# https://projects.niceguyit.biz/T7

# Remove the compose key from the right control key
[[ $DISPLAY ]] && xmodmap -verbose ~/.xmodmaprc
