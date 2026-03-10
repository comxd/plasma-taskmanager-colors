#!/bin/bash
# ONE-SHOT setup script — runs inside the VM (KDE Neon live ISO)
# Called by: launch-vm.sh --setup (via serial console, runs as root)
#
# KDE Neon live ISO user: neon (no password by default)

set -euo pipefail

DEMO_CONFIG="${DEMO_CONFIG:-false}"

if [ "$DEMO_CONFIG" = "true" ]; then
    TOTAL_STEPS=5
else
    TOTAL_STEPS=4
fi

echo "=== Task Manager Colors — VM Setup ==="

# Stop serial getty if present (prevents competing with serial-shell for ttyS0)
systemctl stop serial-getty@ttyS0.service 2>/dev/null || true

# Helper: run a command as the neon user with D-Bus access
# KDE Neon live ISO: neon = UID 1000, D-Bus socket at /run/user/1000/bus
run_as_neon() {
    su - neon -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 $1"
}

# 1. Mount shared folder (may already be mounted by bootstrap)
echo "[1/$TOTAL_STEPS] Mounting shared folder..."
mkdir -p /mnt/plasmoid
if mountpoint -q /mnt/plasmoid; then
    echo "  OK: /mnt/plasmoid already mounted"
else
    mount -t 9p -o trans=virtio,access=any plasmoid /mnt/plasmoid
fi
ls /mnt/plasmoid/metadata.json >/dev/null 2>&1 || { echo "ERROR: shared folder mount failed"; exit 1; }
echo "  OK: /mnt/plasmoid verified"

# 2. Install plasmoid (as neon user)
echo "[2/$TOTAL_STEPS] Installing plasmoid..."
run_as_neon "kpackagetool6 -t Plasma/Applet -r com.comexpertise.plasma.taskmanagercolors 2>/dev/null || true"
run_as_neon "kpackagetool6 -t Plasma/Applet -i /mnt/plasmoid"
echo "  OK: plasmoid installed"

# 3. Add widget to panel via Plasma scripting API (as neon user)
echo "[3/$TOTAL_STEPS] Adding widget to panel..."
bash /mnt/plasmoid/vm/guest/add-to-panel.sh
echo "  OK: widget added to panel"

# 4. Open test apps to populate the task manager
echo "[4/$TOTAL_STEPS] Opening test apps..."
run_as_neon "dolphin ~ &>/dev/null &"
sleep 1
run_as_neon "systemsettings &>/dev/null &"
sleep 1
run_as_neon "kate &>/dev/null &"
sleep 1
run_as_neon "konsole &>/dev/null &"
sleep 1
run_as_neon "plasma-discover &>/dev/null &"
sleep 1
run_as_neon "gwenview &>/dev/null &"
sleep 1
run_as_neon "okular &>/dev/null &"
sleep 1
run_as_neon "kinfocenter &>/dev/null &"

# 5. Apply demo configuration (optional)
if [ "$DEMO_CONFIG" = "true" ]; then
    echo "[5/$TOTAL_STEPS] Applying demo configuration..."
    bash /mnt/plasmoid/vm/guest/demo-config.sh
    echo "  OK: demo config applied"
fi

echo ""
echo "=== Setup complete! ==="
echo "  - 8 apps launched: Dolphin, System Settings, Kate, Konsole, Discover, Gwenview, Okular, Info Center"
if [ "$DEMO_CONFIG" = "true" ]; then
    echo "  - Demo config applied: colors assigned, Nyan Cat on Konsole"
else
    echo "  - Use DEMO_CONFIG=true to pre-assign colors for screenshots"
fi
echo "  - Click the widget icon in the panel to see the popup"
echo "  - Reload after code changes: ./vm/reload-plasmoid.sh"
