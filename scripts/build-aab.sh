#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANDROID_DIR="${APP_ROOT}/android"
LOG_DIR="${ANDROID_DIR}/build/logs"
LOG_FILE="${LOG_DIR}/build-aab-$(date +%Y%m%d-%H%M%S).log"

log() {
  echo "[AAB] $*"
}

open_artifact_dir() {
  local artifact_dir="$1"
  if [[ "${OPEN_ARTIFACT_DIR:-1}" == "1" ]] && command -v open >/dev/null 2>&1; then
    open "${artifact_dir}" >/dev/null 2>&1 || true
  fi
}

if [[ ! -d "${ANDROID_DIR}" ]]; then
  echo "[AAB] Missing Android directory: ${ANDROID_DIR}"
  exit 1
fi

if [[ ! -x "${ANDROID_DIR}/gradlew" ]]; then
  chmod +x "${ANDROID_DIR}/gradlew"
fi

BUILD_TYPE="${AAB_BUILD_TYPE:-release}"

case "${BUILD_TYPE}" in
  debug)
    TASK="bundleDebug"
    EXPECTED_AAB="${ANDROID_DIR}/app/build/outputs/bundle/debug/app-debug.aab"
    ;;
  release)
    TASK="bundleRelease"
    EXPECTED_AAB="${ANDROID_DIR}/app/build/outputs/bundle/release/app-release.aab"
    ;;
  *)
    echo "[AAB] AAB_BUILD_TYPE only supports debug/release. Current: ${BUILD_TYPE}"
    exit 1
    ;;
esac

mkdir -p "${LOG_DIR}"
log "Build type: ${BUILD_TYPE}"
log "Gradle task: ${TASK}"
log "Log file: ${LOG_FILE}"
if ! (cd "${ANDROID_DIR}" && ./gradlew "${TASK}" >"${LOG_FILE}" 2>&1); then
  echo "[AAB] Build failed. Log: ${LOG_FILE}"
  exit 1
fi

AAB_FILE="${EXPECTED_AAB}"
if [[ ! -f "${AAB_FILE}" ]]; then
  AAB_FILE="$(find "${ANDROID_DIR}/app/build/outputs/bundle/${BUILD_TYPE}" -maxdepth 1 -type f -name '*.aab' | sort | tail -n 1 || true)"
fi

if [[ -z "${AAB_FILE}" || ! -f "${AAB_FILE}" ]]; then
  echo "[AAB] AAB output not found. Check log: ${LOG_FILE}"
  exit 1
fi

ARTIFACT_DIR="$(dirname "${AAB_FILE}")"
log "Build succeeded. Artifact directory:"
echo "${ARTIFACT_DIR}"
open_artifact_dir "${ARTIFACT_DIR}"
