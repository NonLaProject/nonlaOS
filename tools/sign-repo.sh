#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE="${NONLA_REPO_SUITE:-stable}"
RELEASE_FILE="${ROOT_DIR}/dist/repo/dists/${SUITE}/Release"
INRELEASE_FILE="${ROOT_DIR}/dist/repo/dists/${SUITE}/InRelease"
RELEASE_GPG_FILE="${ROOT_DIR}/dist/repo/dists/${SUITE}/Release.gpg"

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

require_tool() {
    local tool="$1"
    local package="$2"

    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "Missing required tool: ${tool}" >&2
        echo "Install it with: sudo apt install ${package}" >&2
        exit 1
    fi
}

import_private_key() {
    chmod 700 "${GPG_HOME}"
    export GNUPGHOME="${GPG_HOME}"

    if [[ -n "${NONLA_ARCHIVE_PRIVATE_KEY_FILE:-}" ]]; then
        if [[ ! -f "${NONLA_ARCHIVE_PRIVATE_KEY_FILE}" ]]; then
            echo "Private key file does not exist: ${NONLA_ARCHIVE_PRIVATE_KEY_FILE}" >&2
            exit 1
        fi
        gpg --batch --quiet --import "${NONLA_ARCHIVE_PRIVATE_KEY_FILE}"
        return
    fi

    if [[ -n "${NONLA_ARCHIVE_PRIVATE_KEY:-}" ]]; then
        local key_file
        key_file="$(mktemp)"
        chmod 600 "${key_file}"
        printf '%s\n' "${NONLA_ARCHIVE_PRIVATE_KEY}" > "${key_file}"
        gpg --batch --quiet --import "${key_file}"
        rm -f "${key_file}"
        return
    fi

    echo "Missing nonlaOS archive private key." >&2
    echo "Set NONLA_ARCHIVE_PRIVATE_KEY_FILE or NONLA_ARCHIVE_PRIVATE_KEY." >&2
    exit 1
}

sign_file() {
    local mode="$1"
    local output="$2"
    local input="$3"
    local -a gpg_args=(
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

    case "${mode}" in
        clearsign)
            gpg "${gpg_args[@]}" --clearsign --output "${output}" "${input}"
            ;;
        detach)
            gpg "${gpg_args[@]}" --detach-sign --armor --output "${output}" "${input}"
            ;;
        *)
            echo "Unsupported signing mode: ${mode}" >&2
            exit 1
            ;;
    esac
}

require_tool gpg gnupg

if [[ ! -f "${RELEASE_FILE}" ]]; then
    echo "Missing Release file: ${RELEASE_FILE}" >&2
    echo "Run ./tools/make-repo.sh first." >&2
    exit 1
fi

mkdir -p "${GPG_HOME}"
import_private_key

SECRET_FPR="$(
    gpg --batch --with-colons --list-secret-keys 2>/dev/null \
        | awk -F: '/^fpr:/ {print $10; exit}'
)"

if [[ -z "${SECRET_FPR}" ]]; then
    echo "Imported keyring does not contain a usable secret key." >&2
    exit 1
fi

rm -f "${INRELEASE_FILE}" "${RELEASE_GPG_FILE}"
sign_file clearsign "${INRELEASE_FILE}" "${RELEASE_FILE}"
sign_file detach "${RELEASE_GPG_FILE}" "${RELEASE_FILE}"

cat <<EOF
Signed APT repository metadata:
  ${INRELEASE_FILE}
  ${RELEASE_GPG_FILE}
EOF
