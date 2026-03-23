#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BUILDER_IMAGE="${BUILDER_IMAGE:-truthdb-installer-kernel-builder:local}"
AUTO_BUILD_IMAGE="${AUTO_BUILD_IMAGE:-1}"

KERNEL_VERSION="${KERNEL_VERSION:-6.12}"
KERNEL_CONFIG="${KERNEL_CONFIG:-truthdb-installer-kernel.config}"
KERNEL_TARBALL_SHA256="${KERNEL_TARBALL_SHA256:-b1a2562be56e42afb3f8489d4c2a7ac472ac23098f1ef1c1e40da601f54625eb}"

KEEP_KERNEL_SRC="${KEEP_KERNEL_SRC:-0}"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRIPT_DIR}/dist}"

translate_workspace_path() {
  local value="$1"
  if [[ "$value" == "${WORKSPACE_ROOT}"/* ]]; then
    printf '/work%s' "${value#"${WORKSPACE_ROOT}"}"
    return 0
  fi
  printf '%s' "$value"
}

if [[ "${KERNEL_CONFIG}" = /* ]]; then
  KERNEL_CONFIG_HOST="${KERNEL_CONFIG}"
else
  KERNEL_CONFIG_HOST="${SCRIPT_DIR}/${KERNEL_CONFIG}"
fi

[[ -f "${KERNEL_CONFIG_HOST}" ]] || {
  echo "ERROR: kernel config not found: ${KERNEL_CONFIG_HOST}" >&2
  exit 1
}

if ! docker image inspect "${BUILDER_IMAGE}" >/dev/null 2>&1; then
  if [[ "${AUTO_BUILD_IMAGE}" != "1" ]]; then
    echo "ERROR: builder image not found locally: ${BUILDER_IMAGE}" >&2
    echo "Build it first with ../installer-kernel-builder-image/build_local.sh or set AUTO_BUILD_IMAGE=1." >&2
    exit 1
  fi

  IMAGE_NAME="${BUILDER_IMAGE}" PLATFORM=linux/amd64 \
    "${WORKSPACE_ROOT}/installer-kernel-builder-image/build_local.sh"
fi

OUTPUT_DIR_CONTAINER="$(translate_workspace_path "${OUTPUT_DIR}")"
KERNEL_CONFIG_CONTAINER="$(translate_workspace_path "${KERNEL_CONFIG_HOST}")"

cleanup() {
  if [[ "${KEEP_KERNEL_SRC}" = "1" ]]; then
    return 0
  fi
  rm -rf "${SCRIPT_DIR}/kernel-src" "${SCRIPT_DIR}/linux-${KERNEL_VERSION}" "${SCRIPT_DIR}/linux-${KERNEL_VERSION}.tar.xz"
}

trap cleanup EXIT

docker run --rm -it \
  --platform=linux/amd64 \
  -e "KERNEL_VERSION=${KERNEL_VERSION}" \
  -e "KERNEL_CONFIG=${KERNEL_CONFIG_CONTAINER}" \
  -e "KERNEL_TARBALL_SHA256=${KERNEL_TARBALL_SHA256}" \
  -e "OUTPUT_DIR=${OUTPUT_DIR_CONTAINER}" \
  -e "KEEP_KERNEL_SRC=${KEEP_KERNEL_SRC}" \
  -v "${WORKSPACE_ROOT}:/work" \
  -w /work/installer-kernel \
  "${BUILDER_IMAGE}" \
  bash -lc '
    set -euo pipefail

    build_root="/tmp/truthdb-installer-kernel-build"
    rm -rf "${build_root}"
    mkdir -p "${build_root}"
    cd "${build_root}"

    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
    echo "${KERNEL_TARBALL_SHA256}  linux-${KERNEL_VERSION}.tar.xz" | sha256sum -c -
    tar xf "linux-${KERNEL_VERSION}.tar.xz"
    mv "linux-${KERNEL_VERSION}" kernel-src
    rm -f "linux-${KERNEL_VERSION}.tar.xz"

    cd kernel-src

    cp "${KERNEL_CONFIG}" .config
    make olddefconfig >/dev/null
    echo "Kernel config resolved; building bzImage..."
    make -j"$(nproc)" bzImage

    mkdir -p "${OUTPUT_DIR}"
    cp arch/x86/boot/bzImage "${OUTPUT_DIR}/BOOTX64.EFI"
    (
      cd "${OUTPUT_DIR}"
      sha256sum BOOTX64.EFI > BOOTX64.EFI.sha256
    )

    ls -lh "${OUTPUT_DIR}/BOOTX64.EFI" "${OUTPUT_DIR}/BOOTX64.EFI.sha256"

    if [[ "${KEEP_KERNEL_SRC}" = "1" ]]; then
      rm -rf /work/installer-kernel/kernel-src
      cp -a "${build_root}/kernel-src" /work/installer-kernel/kernel-src
    fi

    rm -rf "${build_root}"

  '
