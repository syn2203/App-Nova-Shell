#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
IOS_DIR="${APP_ROOT}/ios"

if [[ ! -d "${IOS_DIR}" ]]; then
  echo "Missing iOS directory: ${IOS_DIR}"
  exit 1
fi

WORKSPACE_PATH="$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcworkspace' -print -quit || true)"
PROJECT_PATH="$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcodeproj' -print -quit || true)"
TARGET_ARGS=()
DEFAULT_SCHEME=""

if [[ -n "${WORKSPACE_PATH}" ]]; then
  TARGET_ARGS=(-workspace "${WORKSPACE_PATH}")
  DEFAULT_SCHEME="$(basename "${WORKSPACE_PATH}" .xcworkspace)"
elif [[ -n "${PROJECT_PATH}" ]]; then
  TARGET_ARGS=(-project "${PROJECT_PATH}")
  DEFAULT_SCHEME="$(basename "${PROJECT_PATH}" .xcodeproj)"
fi

IOS_SCHEME="${IOS_SCHEME:-${DEFAULT_SCHEME}}"

if command -v xcodebuild >/dev/null 2>&1 && [[ ${#TARGET_ARGS[@]} -gt 0 ]] && [[ -n "${IOS_SCHEME}" ]]; then
  if ! xcodebuild \
    "${TARGET_ARGS[@]}" \
    -scheme "${IOS_SCHEME}" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "${IOS_DIR}/build/DerivedData" \
    clean >/dev/null; then
    echo "xcodebuild clean failed, continuing with file cleanup."
  fi
else
  echo "xcodebuild not found or iOS project/workspace unavailable, skipping xcode clean."
fi

rm -rf "${IOS_DIR}/build"

echo "iOS clean completed."
