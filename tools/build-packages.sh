#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${ROOT_DIR}/packages"
DIST_DIR="${ROOT_DIR}/dist/packages"
WORK_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

mkdir -p "${DIST_DIR}"

for package_dir in "${PACKAGES_DIR}"/*; do
    if [[ ! -d "${package_dir}/debian" ]]; then
        continue
    fi

    package_name="$(basename "${package_dir}")"
    echo "Building ${package_name}"

    build_package_dir="${WORK_DIR}/${package_name}"
    cp -R "${package_dir}" "${build_package_dir}"
    find "${build_package_dir}/debian" -type f -exec chmod 0644 {} +
    chmod 0755 "${build_package_dir}/debian/rules"

    (
        cd "${build_package_dir}"
        dpkg-buildpackage -us -uc -b
    )

    find "${WORK_DIR}" -maxdepth 1 -type f \
        \( -name "${package_name}_*.deb" -o -name "${package_name}_*.buildinfo" -o -name "${package_name}_*.changes" \) \
        -exec mv -f {} "${DIST_DIR}/" \;
done

echo "Packages written to ${DIST_DIR}"
