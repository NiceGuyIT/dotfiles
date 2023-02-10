#!/usr/bin/env bash

export DISPLAY=:0.0
killall plasmashell
#qdbus org.kde.ksmserver /KSMServer logout 0 0 0
qdbus-qt5 org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout 0 0 0


