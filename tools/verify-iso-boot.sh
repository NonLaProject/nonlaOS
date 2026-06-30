#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_DIR="${ROOT_DIR}/dist/iso"
LOG_DIR="${ROOT_DIR}/dist/logs"
ISO_NAME="${NONLA_ISO_NAME:-nonlaOS-0.1-alpha-amd64.iso}"
ISO_FILE="${ISO_DIR}/${ISO_NAME}"
QEMU_TIMEOUT="${NONLA_QEMU_BOOT_TIMEOUT:-90}"

require_tool() {
    local tool="$1"
    local package="$2"

    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "Missing required tool: ${tool}" >&2
        echo "Install it with: sudo apt install ${package}" >&2
        exit 1
    fi
}

if [[ ! -f "${ISO_FILE}" ]]; then
    echo "Missing ISO file: ${ISO_FILE}" >&2
    exit 1
fi

require_tool file file
require_tool isoinfo genisoimage
require_tool xorriso xorriso
require_tool qemu-system-x86_64 qemu-system-x86
require_tool timeout coreutils

mkdir -p "${LOG_DIR}"

file "${ISO_FILE}" | tee "${LOG_DIR}/iso-file.log"
isoinfo -d -i "${ISO_FILE}" | tee "${LOG_DIR}/isoinfo.log"
xorriso -indev "${ISO_FILE}" -report_el_torito plain \
    | tee "${LOG_DIR}/xorriso-el-torito.log"

if ! grep -qi 'El Torito VD version' "${LOG_DIR}/isoinfo.log"; then
    echo "ISO does not expose an El Torito boot catalog." >&2
    exit 1
fi

if ! grep -Eqi 'Boot record|El Torito|boot catalog|EFI' "${LOG_DIR}/xorriso-el-torito.log"; then
    echo "xorriso did not report boot metadata in the ISO." >&2
    exit 1
fi

set +e
timeout "${QEMU_TIMEOUT}" qemu-system-x86_64 \
    -m 2048 \
    -cdrom "${ISO_FILE}" \
    -boot d \
    -nographic \
    -no-reboot \
    > "${LOG_DIR}/qemu-bios-boot.log" 2>&1
qemu_status="$?"
set -e

cat "${LOG_DIR}/qemu-bios-boot.log"

if grep -Eqi 'Boot failed|Could not read from CDROM|No bootable device|not a bootable disk' \
    "${LOG_DIR}/qemu-bios-boot.log"; then
    echo "QEMU BIOS boot reported a boot failure." >&2
    exit 1
fi

case "${qemu_status}" in
    0|124)
        ;;
    *)
        echo "QEMU exited with unexpected status ${qemu_status}." >&2
        exit "${qemu_status}"
        ;;
esac

echo "ISO boot metadata and QEMU BIOS smoke test passed."
