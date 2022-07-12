#!/usr/bin/env bash

set -e

INTERFACE_UP=false

_shutdown () {
    local exitCode=$?
    if [[ ${exitCode} -gt 0 ]]; then
        echo "[ERROR] Received non-zero exit code (${exitCode}) executing the command ${BASH_COMMAND} on line ${LINENO}."
    else
        echo "[INFO] Caught signal to shutdown."
    fi
    
    if [[ "${INTERFACE_UP}" == 'true' ]]; then
        echo "[INFO] Shutting down VPN!"
        sudo /usr/bin/wg-quick down "pia"
    fi
}

trap _shutdown EXIT

source "/shim/iptables-backend.sh"

export VPN_PROTOCOL=wireguard
export PIA_PF=false

cd /manual-connections || exit 1
sudo -E ./run_setup.sh

# sudo /usr/bin/wg-quick up "${INTERFACE}"
INTERFACE_UP=true

source "/shim/killswitch.sh"

sleep infinity &
wait $!