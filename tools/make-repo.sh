#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${ROOT_DIR}/dist/packages"
REPO_DIR="${ROOT_DIR}/dist/repo"

ORIGIN="${NONLA_REPO_ORIGIN:-nonlaOS}"
LABEL="${NONLA_REPO_LABEL:-nonlaOS}"
SUITE="${NONLA_REPO_SUITE:-stable}"
CODENAME="${NONLA_REPO_CODENAME:-stable}"
COMPONENT="${NONLA_REPO_COMPONENT:-main}"
ARCH="${NONLA_REPO_ARCH:-amd64}"

require_tool() {
    local tool="$1"
    local package="$2"

    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "Missing required tool: ${tool}" >&2
        echo "Install it with: sudo apt install ${package}" >&2
        exit 1
    fi
}

require_tool dpkg-scanpackages dpkg-dev
require_tool apt-ftparchive apt-utils
require_tool gzip gzip

shopt -s nullglob
deb_files=("${PACKAGES_DIR}"/*.deb)
shopt -u nullglob

if (( ${#deb_files[@]} == 0 )); then
    echo "No .deb packages found in ${PACKAGES_DIR}" >&2
    echo "Run ./tools/build-packages.sh first." >&2
    exit 1
fi

POOL_DIR="${REPO_DIR}/pool/${COMPONENT}"
DISTS_DIR="${REPO_DIR}/dists/${SUITE}"
BINARY_DIR="${DISTS_DIR}/${COMPONENT}/binary-${ARCH}"

rm -rf "${REPO_DIR}/dists" "${POOL_DIR}"
mkdir -p "${POOL_DIR}" "${BINARY_DIR}"

cp -f "${deb_files[@]}" "${POOL_DIR}/"

(
    cd "${REPO_DIR}"
    dpkg-scanpackages "pool/${COMPONENT}" > "dists/${SUITE}/${COMPONENT}/binary-${ARCH}/Packages"
    gzip -9cn "dists/${SUITE}/${COMPONENT}/binary-${ARCH}/Packages" > "dists/${SUITE}/${COMPONENT}/binary-${ARCH}/Packages.gz"

    apt-ftparchive \
        -o "APT::FTPArchive::Release::Origin=${ORIGIN}" \
        -o "APT::FTPArchive::Release::Label=${LABEL}" \
        -o "APT::FTPArchive::Release::Suite=${SUITE}" \
        -o "APT::FTPArchive::Release::Codename=${CODENAME}" \
        -o "APT::FTPArchive::Release::Architectures=${ARCH}" \
        -o "APT::FTPArchive::Release::Components=${COMPONENT}" \
        release "dists/${SUITE}" > "dists/${SUITE}/Release"
)

cat <<EOF
APT repository written to ${REPO_DIR}

Local test example:
  deb [trusted=yes] file:${REPO_DIR} ${SUITE} ${COMPONENT}

TODO:
  - Run ./tools/sign-repo.sh to generate signed InRelease/Release.gpg.
  - Use [trusted=yes] only for local unsigned testing.
EOF
