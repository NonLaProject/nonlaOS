#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_DIR="${ROOT_DIR}/dist/iso"
ISO_NAME="${NONLA_ISO_NAME:-nonlaOS-0.1-alpha-amd64.iso}"
SOURCEFORGE_HOST="${SOURCEFORGE_HOST:-frs.sourceforge.net}"

require_tool() {
    local tool="$1"
    local package="$2"

    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "Missing required tool: ${tool}" >&2
        echo "Install it with: sudo apt install ${package}" >&2
        exit 1
    fi
}

if [[ -z "${SOURCEFORGE_USER:-}" || -z "${SOURCEFORGE_PROJECT:-}" ]]; then
    echo "SourceForge secrets missing; skipping public upload."
    exit 0
fi

RELEASE_PATH="${SOURCEFORGE_RELEASE_PATH:-/home/frs/project/${SOURCEFORGE_PROJECT}/nonlaOS/0.1-alpha/}"

for file in "${ISO_DIR}/${ISO_NAME}" "${ISO_DIR}/SHA256SUMS" "${ISO_DIR}/SHA256SUMS.gpg"; do
    if [[ ! -f "${file}" ]]; then
        echo "Missing upload file: ${file}" >&2
        exit 1
    fi
done

require_tool rsync rsync
require_tool ssh openssh-client

printf -v quoted_release_path '%q' "${RELEASE_PATH}"
ssh "${SOURCEFORGE_USER}@${SOURCEFORGE_HOST}" "mkdir -p ${quoted_release_path}"

rsync -av --progress \
    "${ISO_DIR}/${ISO_NAME}" \
    "${ISO_DIR}/SHA256SUMS" \
    "${ISO_DIR}/SHA256SUMS.gpg" \
    "${SOURCEFORGE_USER}@${SOURCEFORGE_HOST}:${RELEASE_PATH}"

echo "Uploaded nonlaOS ISO release files to SourceForge path: ${RELEASE_PATH}"
