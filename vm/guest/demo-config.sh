#!/bin/bash
# Apply demo configuration to the Task Manager Colors plasmoid
# Pre-assigns colors to the 8 apps launched by setup-vm.sh
#
# Usage: bash demo-config.sh
# Called by: setup-vm.sh (via serial console, runs as root)
#
# Requires: plasmoid already added to panel (add-to-panel.sh)

set -euo pipefail

PLUGIN_ID="com.comexpertise.plasma.taskmanagercolors"
CONFIG_FILE="/home/neon/.config/plasma-org.kde.plasma.desktop-appletsrc"

# ── Find the applet's config group ──────────────────────────────
# The config file has INI-style sections like:
#   [Containments][2][Applets][15]
#   plugin=com.comexpertise.plasma.taskmanagercolors
# We need the group path segments to build kwriteconfig6 --group flags.

find_applet_group() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: Config file not found: $CONFIG_FILE" >&2
        return 1
    fi

    local current_group=""
    while IFS= read -r line; do
        # Track current INI group
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_group="${BASH_REMATCH[1]}"
        fi
        # Look for our plugin ID
        if [[ "$line" == "plugin=$PLUGIN_ID" ]] && [[ -n "$current_group" ]]; then
            echo "$current_group"
            return 0
        fi
    done < "$CONFIG_FILE"

    echo "ERROR: Applet $PLUGIN_ID not found in $CONFIG_FILE" >&2
    return 1
}

echo "  Finding plasmoid config group..."
APPLET_GROUP=$(find_applet_group)

echo "  Applet group: [$APPLET_GROUP]"

# Build --group flags for kwriteconfig6
# Input: "Containments][2][Applets][15" → segments: Containments, 2, Applets, 15
# We append Configuration and General for the config subgroup
build_group_flags() {
    local group_str="$1"
    local flags=()
    # Split on "][" to get individual group segments
    IFS=']' read -ra parts <<< "$group_str"
    for part in "${parts[@]}"; do
        # Remove leading "["
        part="${part#\[}"
        if [ -n "$part" ]; then
            flags+=("--group" "$part")
        fi
    done
    # Append Configuration/General subgroup
    flags+=("--group" "Configuration" "--group" "General")
    echo "${flags[@]}"
}

GROUP_FLAGS=$(build_group_flags "$APPLET_GROUP")

# Helper: write a config key using kwriteconfig6
write_config() {
    local key="$1"
    local value="$2"
    # shellcheck disable=SC2086
    kwriteconfig6 --file "$CONFIG_FILE" $GROUP_FLAGS --key "$key" "$value"
}

# ── Demo color palette ──────────────────────────────────────────
# Harmonious colors assigned to each app, Nyan Cat on Konsole
#
# Format: "appId": "#rrggbb" or "appId": "#rrggbb:nyan"
# See CLAUDE.md for appColorMap JSON-in-String format

APP_COLOR_MAP='{
  "org.kde.dolphin": "#2196F3",
  "systemsettings": "#9C27B0",
  "org.kde.kate": "#4CAF50",
  "org.kde.konsole": "#FF5722:nyan",
  "org.kde.discover": "#FF9800",
  "org.kde.gwenview": "#00BCD4",
  "org.kde.okular": "#F44336",
  "org.kde.kinfocenter": "#607D8B"
}'

# Compact JSON (single line, no whitespace) for KConfig storage
APP_COLOR_MAP_COMPACT=$(echo "$APP_COLOR_MAP" | tr -d '\n' | sed 's/  *//g')

# ── Write config values ─────────────────────────────────────────

echo "  Writing demo configuration..."

write_config "appColorMap" "$APP_COLOR_MAP_COMPACT"
write_config "colorMode" "background"
write_config "backgroundOpacity" "0.55"
write_config "isEnabled" "true"
write_config "rainbowStyle" "wave"
write_config "rainbowSpeed" "3.0"

echo "  Demo config applied:"
echo "    - 8 apps with assigned colors"
echo "    - Nyan Cat enabled on Konsole"
echo "    - Display mode: background (55% opacity)"
echo "    - Rainbow style: wave"
