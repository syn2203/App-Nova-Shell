#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANDROID_DIR="${APP_ROOT}/android"
LOG_DIR="${ANDROID_DIR}/build/logs"
LOG_FILE="${LOG_DIR}/build-apk-$(date +%Y%m%d-%H%M%S).log"

log() {
  echo "[APK] $*"
}

open_artifact_dir() {
  local artifact_dir="$1"
  if [[ "${OPEN_ARTIFACT_DIR:-1}" == "1" ]] && command -v open >/dev/null 2>&1; then
    open "${artifact_dir}" >/dev/null 2>&1 || true
  fi
}

if [[ ! -d "${ANDROID_DIR}" ]]; then
  echo "[APK] Missing Android directory: ${ANDROID_DIR}"
  exit 1
fi

if [[ ! -x "${ANDROID_DIR}/gradlew" ]]; then
  chmod +x "${ANDROID_DIR}/gradlew"
fi

BUILD_TYPE="${APK_BUILD_TYPE:-debug}"

case "${BUILD_TYPE}" in
  debug)
    TASK="assembleDebug"
    APK_PATH="${ANDROID_DIR}/app/build/outputs/apk/debug/app-debug.apk"
    ;;
  release)
    TASK="assembleRelease"
    APK_PATH="${ANDROID_DIR}/app/build/outputs/apk/release/app-release.apk"
    ;;
  *)
    echo "[APK] APK_BUILD_TYPE only supports debug/release. Current: ${BUILD_TYPE}"
    exit 1
    ;;
esac

mkdir -p "${LOG_DIR}"
log "Build type: ${BUILD_TYPE}"
log "Gradle task: ${TASK}"
log "Log file: ${LOG_FILE}"
if ! (cd "${ANDROID_DIR}" && ./gradlew "${TASK}" >"${LOG_FILE}" 2>&1); then
  echo "[APK] Build failed. Log: ${LOG_FILE}"
  exit 1
fi

if [[ -f "${APK_PATH}" ]]; then
  ARTIFACT_DIR="$(dirname "${APK_PATH}")"
  log "Build succeeded. Artifact directory:"
  echo "${ARTIFACT_DIR}"
  open_artifact_dir "${ARTIFACT_DIR}"
else
  echo "[APK] APK output not found: ${APK_PATH}"
  exit 1
fi
