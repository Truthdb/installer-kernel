#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

"${SCRIPT_DIR}/build_in_container.sh"

OUTPUT_DIR_HOST="${OUTPUT_DIR:-${SCRIPT_DIR}/dist}"
if [[ "${OUTPUT_DIR_HOST}" != /* ]]; then
  OUTPUT_DIR_HOST="${SCRIPT_DIR}/${OUTPUT_DIR_HOST}"
fi

KERNEL_SRC="${OUTPUT_DIR_HOST}/BOOTX64.EFI" \
  "${WORKSPACE_ROOT}/installer-iso/build_in_container.sh"
