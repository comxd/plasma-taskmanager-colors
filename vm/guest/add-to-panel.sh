#!/bin/bash
# Add the Task Manager Colors widget to the first panel found
# Handles both neon user and root execution (serial shell runs as root)
#
# Usage: bash add-to-panel.sh
# Called by: setup-vm.sh (via serial console, runs as root)

set -euo pipefail

WIDGET_ID="com.comexpertise.plasma.taskmanagercolors"

# Plasma scripting JS — single line to avoid quoting issues with su -c
SCRIPT="var p=panels();if(p.length>0){p[0].addWidget(\"$WIDGET_ID\");}"

if [ "$(whoami)" = "root" ]; then
    su - neon -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '$SCRIPT'"
else
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$SCRIPT"
fi
