#!/usr/bin/env bash

# Chrome scaling does not work correctly when the DPI is not 96x96
# https://bugs.chromium.org/p/chromium/issues/detail?id=490964
if ! xdpyinfo | grep -q resolution.*96x96
then
    echo "Fixing resolution"
    echo -n "Current "; xdpyinfo | grep resolution
    xrandr --dpi 96x96
    echo -n "  Fixed "; xdpyinfo | grep resolution
fi
