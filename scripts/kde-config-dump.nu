#!/usr/bin/env nu

# This is an example config
# Containment group == 27
# Applet group == 48
# [Containments][27][Applets][48][Configuration][General]
# launchers=
# sortingStrategy=0

let servicename = 'org.kde.plasmashell'
let path = '/PlasmaShell'
let method = 'org.kde.PlasmaShell.evaluateScript'
let script = (open dump-widget-config.js)

# qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript $script
qdbus6 $servicename $path $method $script | from json
