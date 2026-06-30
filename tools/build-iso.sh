#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
REPO_DIR="${DIST_DIR}/repo"
LIVE_WORK_DIR="${DIST_DIR}/live-build"
ISO_DIR="${DIST_DIR}/iso"
LOG_DIR="${DIST_DIR}/logs"
ISO_NAME="${NONLA_ISO_NAME:-nonlaOS-0.1-alpha-amd64.iso}"
LB_DISTRIBUTION="${NONLA_LB_DISTRIBUTION:-trixie}"
LB_ARCH="${NONLA_LB_ARCH:-amd64}"
LB_REPO_MODE="${NONLA_LB_REPO_MODE:-http}"
LB_REPO_PORT="${NONLA_LB_REPO_PORT:-18080}"
LB_REPO_COMPONENT="${NONLA_REPO_COMPONENT:-main}"
LB_REPO_SUITE="${NONLA_REPO_SUITE:-stable}"

require_tool() {
    local tool="$1"
    local package="$2"

    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "Missing required tool: ${tool}" >&2
        echo "Install it with: sudo apt install ${package}" >&2
        exit 1
    fi
}

run_as_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    else
        require_tool sudo sudo
        sudo "$@"
    fi
}

cleanup_http_server() {
    if [[ -n "${REPO_HTTP_PID:-}" ]]; then
        kill "${REPO_HTTP_PID}" >/dev/null 2>&1 || true
        wait "${REPO_HTTP_PID}" >/dev/null 2>&1 || true
    fi
}

require_tool lb live-build
require_tool python3 python3
require_tool tee coreutils

cd "${ROOT_DIR}"

./tools/build-packages.sh
./tools/make-repo.sh

run_as_root rm -rf "${LIVE_WORK_DIR}"
mkdir -p "${LIVE_WORK_DIR}" "${ISO_DIR}" "${LOG_DIR}"

cp -R "${ROOT_DIR}/iso/config" "${LIVE_WORK_DIR}/config"
mkdir -p "${LIVE_WORK_DIR}/config/archives"

case "${LB_REPO_MODE}" in
    http)
        REPO_SOURCE="deb [trusted=yes] http://127.0.0.1:${LB_REPO_PORT}/ ${LB_REPO_SUITE} ${LB_REPO_COMPONENT}"
        trap cleanup_http_server EXIT
        (
            cd "${REPO_DIR}"
            python3 -m http.server "${LB_REPO_PORT}" --bind 127.0.0.1
        ) >/tmp/nonla-live-build-repo-http.log 2>&1 &
        REPO_HTTP_PID="$!"
        sleep 2
        ;;
    file)
        REPO_ABS="$(cd "${REPO_DIR}" && pwd)"
        REPO_SOURCE="deb [trusted=yes] file:${REPO_ABS} ${LB_REPO_SUITE} ${LB_REPO_COMPONENT}"
        ;;
    *)
        echo "Unsupported NONLA_LB_REPO_MODE=${LB_REPO_MODE}; use http or file." >&2
        exit 1
        ;;
esac

printf '%s\n' "${REPO_SOURCE}" > "${LIVE_WORK_DIR}/config/archives/nonla-local.list.chroot"

(
    cd "${LIVE_WORK_DIR}"

    lb config \
        --mode debian \
        --distribution "${LB_DISTRIBUTION}" \
        --architectures "${LB_ARCH}" \
        --binary-images iso-hybrid \
        --archive-areas main \
        --apt-recommends true \
        --debian-installer false \
        --iso-application "nonlaOS 0.1 Alpha" \
        --iso-publisher "nonlaOS" \
        --iso-volume "nonlaOS 0.1 Alpha ${LB_ARCH}"

    run_as_root lb build 2>&1 | tee "${LOG_DIR}/live-build.log"
)

generated_iso="$(find "${LIVE_WORK_DIR}" -maxdepth 1 -type f -name '*.iso' | head -n 1)"
if [[ -z "${generated_iso}" ]]; then
    echo "live-build completed but no ISO was found in ${LIVE_WORK_DIR}" >&2
    exit 1
fi

run_as_root cp -f "${generated_iso}" "${ISO_DIR}/${ISO_NAME}"
run_as_root chown "$(id -u):$(id -g)" "${ISO_DIR}/${ISO_NAME}" || true

cat <<EOF
ISO written to ${ISO_DIR}/${ISO_NAME}
Build log written to ${LOG_DIR}/live-build.log
EOF
