#!/bin/bash
# Shared serial console helpers for host scripts
#
# Usage:
#   source "$(dirname "$0")/lib/serial.sh"
#
# Provides:
#   SERIAL_SOCK — path to the serial Unix socket
#   vm_serial() — send a command to the VM via serial console
#   check_serial_sock() — exit with error if socket is missing

SERIAL_SOCK="/tmp/task-manager-colors-vm-serial.sock"

vm_serial() {
    # Keep connection open briefly so the command executes and we can read output
    (echo "$1"; sleep 2) | socat -t3 - UNIX:"$SERIAL_SOCK" 2>/dev/null
}

check_serial_sock() {
    if [ ! -S "$SERIAL_SOCK" ]; then
        echo "ERROR: Serial socket not found at $SERIAL_SOCK"
        echo "  Is the VM running?  → ./vm/launch-vm.sh"
        echo "  Setup done?         → ./vm/launch-vm.sh --setup"
        exit 1
    fi
}
