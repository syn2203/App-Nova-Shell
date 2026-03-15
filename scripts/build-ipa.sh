#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
IOS_DIR="${APP_ROOT}/ios"

DEFAULT_WORKSPACE_PATH="$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcworkspace' -print -quit || true)"
DEFAULT_PROJECT_PATH="$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcodeproj' -print -quit || true)"

WORKSPACE_PATH="${IOS_WORKSPACE_PATH:-${DEFAULT_WORKSPACE_PATH}}"
PROJECT_PATH="${IOS_PROJECT_PATH:-${DEFAULT_PROJECT_PATH}}"
DEFAULT_SCHEME=""
CONFIGURATION="${IOS_CONFIGURATION:-Release}"
EXPORT_OPTIONS_PLIST="${IOS_EXPORT_OPTIONS_PLIST:-${IOS_DIR}/exportOptions.plist}"
VERBOSE="${IPA_VERBOSE:-0}"
LOG_DIR="${IOS_DIR}/build/logs"
LOG_FILE="${LOG_DIR}/build-ipa-$(date +%Y%m%d-%H%M%S).log"

if [[ -n "${WORKSPACE_PATH}" ]]; then
  DEFAULT_SCHEME="$(basename "${WORKSPACE_PATH}" .xcworkspace)"
elif [[ -n "${PROJECT_PATH}" ]]; then
  DEFAULT_SCHEME="$(basename "${PROJECT_PATH}" .xcodeproj)"
fi

SCHEME="${IOS_SCHEME:-${DEFAULT_SCHEME}}"
ARCHIVE_PATH="${IOS_ARCHIVE_PATH:-${IOS_DIR}/build/${SCHEME}.xcarchive}"
EXPORT_PATH="${IOS_EXPORT_PATH:-${IOS_DIR}/build/ipa}"

log() {
  echo "[IPA] $*"
}

open_artifact_dir() {
  local artifact_dir="$1"
  if [[ "${OPEN_ARTIFACT_DIR:-1}" == "1" ]] && command -v open >/dev/null 2>&1; then
    open "${artifact_dir}" >/dev/null 2>&1 || true
  fi
}

if [[ ! -d "${IOS_DIR}" ]]; then
  echo "[IPA] Missing iOS directory: ${IOS_DIR}"
  exit 1
fi

if [[ -z "${WORKSPACE_PATH}" && -z "${PROJECT_PATH}" ]]; then
  echo "[IPA] No workspace or project found in: ${IOS_DIR}"
  exit 1
fi

if [[ -z "${SCHEME}" ]]; then
  echo "[IPA] Unable to determine an iOS scheme. Set IOS_SCHEME explicitly."
  exit 1
fi

if [[ ! -f "${EXPORT_OPTIONS_PLIST}" ]]; then
  echo "[IPA] Export options plist not found: ${EXPORT_OPTIONS_PLIST}"
  echo "[IPA] Create ios/exportOptions.plist or set IOS_EXPORT_OPTIONS_PLIST."
  exit 1
fi

if [[ -n "${WORKSPACE_PATH}" ]]; then
  BUILD_TARGET_ARGS=(-workspace "${WORKSPACE_PATH}")
  BUILD_TARGET_DESC="workspace: ${WORKSPACE_PATH}"
else
  BUILD_TARGET_ARGS=(-project "${PROJECT_PATH}")
  BUILD_TARGET_DESC="project: ${PROJECT_PATH}"
fi

mkdir -p "$(dirname "${ARCHIVE_PATH}")" "${EXPORT_PATH}" "${LOG_DIR}"
log "Configuration: ${CONFIGURATION}"
log "${BUILD_TARGET_DESC}"
log "Scheme: ${SCHEME}"
log "Log file: ${LOG_FILE}"

run_xcodebuild() {
  local step="$1"
  shift
  log "Running step: ${step}"
  if [[ "${VERBOSE}" == "1" ]]; then
    xcodebuild "$@" 2>&1 | tee -a "${LOG_FILE}"
  else
    if ! xcodebuild "$@" >>"${LOG_FILE}" 2>&1; then
      echo "[IPA] ${step} failed. Log: ${LOG_FILE}"
      exit 1
    fi
  fi
}

run_xcodebuild "archive" \
  "${BUILD_TARGET_ARGS[@]}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -sdk iphoneos \
  -archivePath "${ARCHIVE_PATH}" \
  clean archive \
  -allowProvisioningUpdates

run_xcodebuild "exportArchive" \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
  -allowProvisioningUpdates

IPA_FILE="$(find "${EXPORT_PATH}" -maxdepth 1 -name '*.ipa' | head -n 1 || true)"
if [[ -n "${IPA_FILE}" && -f "${IPA_FILE}" ]]; then
  ARTIFACT_DIR="$(dirname "${IPA_FILE}")"
  log "Build succeeded. Artifact directory:"
  echo "${ARTIFACT_DIR}"
  open_artifact_dir "${ARTIFACT_DIR}"
else
  echo "[IPA] IPA output not found. Export directory: ${EXPORT_PATH}"
  echo "[IPA] Log file: ${LOG_FILE}"
  exit 1
fi
