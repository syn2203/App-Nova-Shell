#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANDROID_DIR="${APP_ROOT}/android"

if [[ ! -d "${ANDROID_DIR}" ]]; then
  echo "Missing Android directory: ${ANDROID_DIR}"
  exit 1
fi

if [[ ! -x "${ANDROID_DIR}/gradlew" ]]; then
  chmod +x "${ANDROID_DIR}/gradlew"
fi

(
  cd "${ANDROID_DIR}"
  ./gradlew clean
)

rm -rf \
  "${ANDROID_DIR}/app/.cxx" \
  "${ANDROID_DIR}/app/build" \
  "${ANDROID_DIR}/app/build/intermediates" \
  "${ANDROID_DIR}/app/build/generated" \
  "${ANDROID_DIR}/app/build/tmp" \
  "${ANDROID_DIR}/build" \
  "${ANDROID_DIR}/.gradle" \
  "${ANDROID_DIR}/.cxx"

echo "Android clean completed."
