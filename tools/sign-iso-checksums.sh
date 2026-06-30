#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_DIR="${ROOT_DIR}/dist/iso"
ISO_NAME="${NONLA_ISO_NAME:-nonlaOS-0.1-alpha-amd64.iso}"
ISO_FILE="${ISO_DIR}/${ISO_NAME}"
SUMS_FILE="${ISO_DIR}/SHA256SUMS"
SUMS_SIG_FILE="${ISO_DIR}/SHA256SUMS.gpg"

require_tool() {
    local tool="$1"
    local package="$2"

    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "Missing required tool: ${tool}" >&2
        echo "Install it with: sudo apt install ${package}" >&2
        exit 1
    fi
}

require_tool sha256sum coreutils
require_tool gpg gnupg

if [[ ! -f "${ISO_FILE}" ]]; then
    echo "Missing ISO file: ${ISO_FILE}" >&2
    echo "Run ./tools/build-iso.sh first." >&2
    exit 1
fi

(
    cd "${ISO_DIR}"
    sha256sum "${ISO_NAME}" > "${SUMS_FILE}"
)

GPG_HOME_CREATED=0
if [[ -n "${NONLA_GPG_HOME:-}" ]]; then
    GPG_HOME="${NONLA_GPG_HOME}"
else
    GPG_HOME="$(mktemp -d)"
    GPG_HOME_CREATED=1
fi

cleanup() {
    if [[ "${GPG_HOME_CREATED}" == "1" ]]; then
        rm -rf "${GPG_HOME}"
    fi
}
trap cleanup EXIT

chmod 700 "${GPG_HOME}"
export GNUPGHOME="${GPG_HOME}"

if [[ -n "${NONLA_ARCHIVE_PRIVATE_KEY_FILE:-}" ]]; then
    if [[ ! -f "${NONLA_ARCHIVE_PRIVATE_KEY_FILE}" ]]; then
        echo "Private key file does not exist: ${NONLA_ARCHIVE_PRIVATE_KEY_FILE}" >&2
        exit 1
    fi
    gpg --batch --quiet --import "${NONLA_ARCHIVE_PRIVATE_KEY_FILE}"
elif [[ -n "${NONLA_ARCHIVE_PRIVATE_KEY:-}" ]]; then
    key_file="$(mktemp)"
    chmod 600 "${key_file}"
    printf '%s\n' "${NONLA_ARCHIVE_PRIVATE_KEY}" > "${key_file}"
    gpg --batch --quiet --import "${key_file}"
    rm -f "${key_file}"
else
    echo "Missing nonlaOS archive private key." >&2
    echo "Set NONLA_ARCHIVE_PRIVATE_KEY_FILE or NONLA_ARCHIVE_PRIVATE_KEY." >&2
    exit 1
fi

gpg_args=(
    --batch
    --yes
    --pinentry-mode loopback
    --digest-algo SHA256
)

if [[ -n "${NONLA_ARCHIVE_KEY_PASSPHRASE:-}" ]]; then
    gpg_args+=(--passphrase "${NONLA_ARCHIVE_KEY_PASSPHRASE}")
else
    gpg_args+=(--passphrase "")
fi

if [[ -n "${NONLA_GPG_KEY_ID:-}" ]]; then
    gpg_args+=(--local-user "${NONLA_GPG_KEY_ID}")
fi

rm -f "${SUMS_SIG_FILE}"
gpg "${gpg_args[@]}" --detach-sign --armor --output "${SUMS_SIG_FILE}" "${SUMS_FILE}"

cat <<EOF
Signed ISO checksum:
  ${SUMS_FILE}
  ${SUMS_SIG_FILE}
EOF
