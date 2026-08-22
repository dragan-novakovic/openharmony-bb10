#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BIN="${REPO_BIN:-${ROOT}/.repo/repo/repo}"
KEYBOARD_REPO="https://github.com/dragan-novakovic/openharmony-bb10-keyboard.git"
KEYBOARD_HAP="https://github.com/dragan-novakovic/openharmony-bb10-keyboard/releases/download/v0.1.0/kikaInput.hap"

if [[ ! -d "${ROOT}/.repo" ]]; then
  echo "OpenHarmony repo workspace not found: ${ROOT}" >&2
  exit 1
fi

mkdir -p "${ROOT}/.repo/local_manifests"
cp "${SCRIPT_DIR}/local_manifests/bb10.xml" "${ROOT}/.repo/local_manifests/bb10.xml"

"${REPO_BIN}" sync --force-sync \
  applications/standard/launcher \
  applications/standard/screenlock \
  applications/standard/systemui

temporary="$(mktemp -d)"
trap 'rm -rf "${temporary}"' EXIT
git clone --depth 1 "${KEYBOARD_REPO}" "${temporary}/keyboard"

keyboard_target="${ROOT}/applications/standard/app_samples/code/Solutions/InputMethod/KikaInput"
mkdir -p "${keyboard_target}"
rsync -a --delete \
  --exclude .git \
  --exclude build \
  --exclude .hvigor \
  --exclude oh_modules \
  "${temporary}/keyboard/" "${keyboard_target}/"

curl -fL "${KEYBOARD_HAP}" \
  -o "${ROOT}/applications/standard/hap/kikaInput.hap"

echo "BB10 shell sources installed in ${ROOT}"
