#!/usr/bin/env bash

# Build Flutter artifacts and optionally upload them to a server or App Store Connect.
# Credentials are read from environment variables; nothing sensitive belongs in git.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${RELEASE_OUTPUT_DIR:-${PROJECT_ROOT}/dist}"
UPDATE_CHANNEL="${UPDATE_CHANNEL:-gitee}"
DRY_RUN="false"
SKIP_CLEAN="false"

log() { printf '[release] %s\n' "$*"; }
warn() { printf '[release] WARNING: %s\n' "$*" >&2; }
die() { printf '[release] ERROR: %s\n' "$*" >&2; exit 1; }

run() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

copy_artifacts() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf '+ copy artifacts to %q\n' "${OUTPUT_DIR}"
    return 0
  fi
  mkdir -p "${OUTPUT_DIR}"
  "$@"
}

usage() {
  cat <<'EOF'
Usage:
  scripts/release.sh build <target> [options]
  scripts/release.sh upload-server [options]
  scripts/release.sh upload-asc [options]
  scripts/release.sh release <target> [options]

Targets:
  android-apk   Android APK (split per ABI)
  android-aab   Android App Bundle
  ios           iOS IPA (requires macOS, Xcode and signing)
  macos         macOS application
  windows       Windows MSIX (run on Windows)
  linux         Linux application (run on Linux)
  web           WebAssembly web build
  all           Build every target supported by the current host

Options:
  --output-dir DIR       Artifact directory (default: ./dist)
  --channel NAME         UPDATE_CHANNEL dart define (default: gitee)
  --skip-clean           Do not run flutter clean before building
  --dry-run              Print commands without executing them
  --help                 Show this help

Server upload environment variables:
  RELEASE_SERVER_METHOD  scp (default), rsync, or curl
  RELEASE_SERVER_URL     Destination URL/path. Examples:
                         user@example.com:/srv/releases/ios-club
                         https://upload.example.com/releases
  RELEASE_SERVER_TOKEN   Bearer token (curl only, optional)

App Store Connect environment variables:
  ASC_API_KEY_ID         App Store Connect API key ID
  ASC_ISSUER_ID          App Store Connect issuer ID
  ASC_API_KEY_PATH       Path to the .p8 private key file
  ASC_BUNDLE_TYPE        ios (default) or osx

Examples:
  scripts/release.sh build android-aab --channel appstore
  scripts/release.sh release ios --output-dir ./dist
  RELEASE_SERVER_URL=user@host:/srv/releases scripts/release.sh upload-server
  ASC_API_KEY_ID=ABC ASC_ISSUER_ID=... ASC_API_KEY_PATH=./private/AuthKey_ABC.p8 \
    scripts/release.sh upload-asc
EOF
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

flutter_args=(--no-tree-shake-icons "--dart-define=UPDATE_CHANNEL=${UPDATE_CHANNEL}")

build_target() {
  local target="$1"
  mkdir -p "${OUTPUT_DIR}"

  case "${target}" in
    android-apk)
      require_command flutter
      run flutter build apk --release "${flutter_args[@]}" --split-per-abi
      copy_artifacts find "${PROJECT_ROOT}/build/app/outputs/flutter-apk" -maxdepth 1 -type f -name '*.apk' -exec cp {} "${OUTPUT_DIR}/" \;
      ;;
    android-aab)
      require_command flutter
      run flutter build appbundle --release "${flutter_args[@]}"
      copy_artifacts cp "${PROJECT_ROOT}/build/app/outputs/bundle/release/app-release.aab" "${OUTPUT_DIR}/"
      ;;
    ios)
      [[ "$(uname -s)" == "Darwin" ]] || die "iOS builds require macOS and Xcode"
      require_command flutter
      run flutter build ipa --release "${flutter_args[@]}"
      copy_artifacts cp "${PROJECT_ROOT}/build/ios/ipa/"*.ipa "${OUTPUT_DIR}/"
      ;;
    macos)
      [[ "$(uname -s)" == "Darwin" ]] || die "macOS builds require macOS"
      require_command flutter
      run flutter build macos --release "${flutter_args[@]}"
      local app_path="${PROJECT_ROOT}/build/macos/Build/Products/Release/ios_club_app.app"
      if [[ "${DRY_RUN}" == "true" ]]; then
        printf '+ zip -qry %q %q\n' "${OUTPUT_DIR}/ios_club_app-macos.zip" "${app_path}"
      else
        [[ -d "${app_path}" ]] || die "macOS app not found at ${app_path}"
        (cd "$(dirname "${app_path}")" && run zip -qry "${OUTPUT_DIR}/ios_club_app-macos.zip" "$(basename "${app_path}")")
      fi
      ;;
    windows)
      [[ "$(uname -s)" == "MINGW"* || "$(uname -s)" == "MSYS"* || "$(uname -s)" == "CYGWIN"* ]] || die "Windows builds require Windows"
      require_command flutter
      run flutter build windows --release "${flutter_args[@]}"
      require_command dart
      (cd "${PROJECT_ROOT}" && run dart run msix:create --store)
      copy_artifacts find "${PROJECT_ROOT}/build/windows" -type f -name '*.msix' -exec cp {} "${OUTPUT_DIR}/" \;
      ;;
    linux)
      [[ "$(uname -s)" == "Linux" ]] || die "Linux builds require Linux"
      require_command flutter
      run flutter build linux --release "${flutter_args[@]}"
      if [[ "${DRY_RUN}" == "true" ]]; then
        printf '+ tar -czf %q %q\n' "${OUTPUT_DIR}/ios_club_app-linux-x64.tar.gz" "${PROJECT_ROOT}/build/linux/x64/release/bundle"
      else
        (cd "${PROJECT_ROOT}/build/linux/x64/release/bundle" && run tar -czf "${OUTPUT_DIR}/ios_club_app-linux-x64.tar.gz" .)
      fi
      ;;
    web)
      require_command flutter
      run flutter build web --release --wasm "${flutter_args[@]}"
      if [[ "${DRY_RUN}" == "true" ]]; then
        printf '+ zip -qry %q %q\n' "${OUTPUT_DIR}/ios_club_app-web.zip" "${PROJECT_ROOT}/build/web"
      else
        (cd "${PROJECT_ROOT}/build/web" && run zip -qry "${OUTPUT_DIR}/ios_club_app-web.zip" .)
      fi
      ;;
    *) die "Unknown target: ${target}" ;;
  esac
  log "Built ${target} artifacts in ${OUTPUT_DIR}"
}

build_all() {
  local targets=(android-apk android-aab web)
  case "$(uname -s)" in
    Darwin) targets+=(ios macos) ;;
    Linux) targets+=(linux) ;;
    MINGW*|MSYS*|CYGWIN*) targets+=(windows) ;;
  esac
  local target
  for target in "${targets[@]}"; do
    build_target "${target}"
  done
}

upload_server() {
  [[ -n "${RELEASE_SERVER_URL:-}" ]] || die "Set RELEASE_SERVER_URL before uploading"
  local method="${RELEASE_SERVER_METHOD:-scp}"
  local files=()
  while IFS= read -r -d '' file; do files+=("${file}"); done < <(find "${OUTPUT_DIR}" -maxdepth 1 -type f -print0)
  ((${#files[@]} > 0)) || die "No artifacts found in ${OUTPUT_DIR}; run build first"

  case "${method}" in
    scp)
      require_command scp
      run scp "${files[@]}" "${RELEASE_SERVER_URL}"
      ;;
    rsync)
      require_command rsync
      run rsync -av --progress "${files[@]}" "${RELEASE_SERVER_URL%/}/"
      ;;
    curl)
      require_command curl
      local file
      for file in "${files[@]}"; do
        local curl_args=(-fS --upload-file "${file}")
        if [[ -n "${RELEASE_SERVER_TOKEN:-}" ]]; then
          curl_args+=( -H "Authorization: Bearer ${RELEASE_SERVER_TOKEN}" )
        fi
        run curl "${curl_args[@]}" "${RELEASE_SERVER_URL%/}/$(basename "${file}")"
      done
      ;;
    *) die "RELEASE_SERVER_METHOD must be scp, rsync, or curl (got ${method})" ;;
  esac
  log "Uploaded artifacts from ${OUTPUT_DIR}"
}

upload_asc() {
  [[ -n "${ASC_API_KEY_ID:-}" ]] || die "Set ASC_API_KEY_ID before uploading"
  [[ -n "${ASC_ISSUER_ID:-}" ]] || die "Set ASC_ISSUER_ID before uploading"
  [[ -n "${ASC_API_KEY_PATH:-}" ]] || die "Set ASC_API_KEY_PATH before uploading"
  [[ -f "${ASC_API_KEY_PATH}" ]] || die "ASC API key file not found: ${ASC_API_KEY_PATH}"
  require_command xcrun
  local ipa
  ipa="$(find "${OUTPUT_DIR}" -maxdepth 1 -type f -name '*.ipa' -print -quit)"
  [[ -n "${ipa}" ]] || die "No .ipa artifact found in ${OUTPUT_DIR}; build iOS first"
  # altool discovers AuthKey_<ID>.p8 from a fixed private_keys directory.
  # Use a temporary directory so callers can keep keys anywhere on disk.
  local auth_dir key_name
  auth_dir="$(mktemp -d "${TMPDIR:-/tmp}/ios-club-asc.XXXXXX")"
  key_name="AuthKey_${ASC_API_KEY_ID}.p8"
  mkdir -p "${auth_dir}/private_keys"
  ln -s "$(cd "$(dirname "${ASC_API_KEY_PATH}")" && pwd)/$(basename "${ASC_API_KEY_PATH}")" "${auth_dir}/private_keys/${key_name}"
  local upload_status=0
  (cd "${auth_dir}" && run xcrun altool --upload-app --type "${ASC_BUNDLE_TYPE:-ios}" --file "${ipa}" \
    --api-key "${ASC_API_KEY_ID}" --api-issuer "${ASC_ISSUER_ID}") || upload_status=$?
  rm -rf "${auth_dir}"
  ((upload_status == 0)) || return "${upload_status}"
  log "Uploaded ${ipa} to App Store Connect"
}

parse_options() {
  while (($#)); do
    case "$1" in
      --output-dir) (($# >= 2)) || die "--output-dir requires a value"; OUTPUT_DIR="$2"; shift 2 ;;
      --channel) (($# >= 2)) || die "--channel requires a value"; UPDATE_CHANNEL="$2"; flutter_args=(--no-tree-shake-icons "--dart-define=UPDATE_CHANNEL=${UPDATE_CHANNEL}"); shift 2 ;;
      --skip-clean) SKIP_CLEAN="true"; shift ;;
      --dry-run) DRY_RUN="true"; shift ;;
      --help|-h) usage; exit 0 ;;
      *) die "Unknown option: $1" ;;
    esac
  done
}

main() {
  (($# > 0)) || { usage; exit 2; }
  [[ "$1" == "--help" || "$1" == "-h" ]] && { usage; exit 0; }
  local action="$1"; shift
  local target=""
  if [[ "${action}" == "build" || "${action}" == "release" ]]; then
    (($# > 0)) || die "${action} requires a target"
    target="$1"; shift
  fi
  parse_options "$@"

  if [[ "${OUTPUT_DIR}" != /* ]]; then
    OUTPUT_DIR="${PROJECT_ROOT}/${OUTPUT_DIR}"
  fi

  if [[ "${SKIP_CLEAN}" != "true" && ( "${action}" == "build" || "${action}" == "release" ) ]]; then
    require_command flutter
    run flutter clean
    run flutter pub get
  fi

  case "${action}" in
    build) [[ "${target}" == "all" ]] && build_all || build_target "${target}" ;;
    upload-server) upload_server ;;
    upload-asc) upload_asc ;;
    release)
      [[ "${target}" == "all" ]] && build_all || build_target "${target}"
      upload_server
      if [[ "${target}" == "ios" ]] || [[ "${target}" == "all" && -n "$(find "${OUTPUT_DIR}" -maxdepth 1 -type f -name '*.ipa' -print -quit)" ]]; then
        upload_asc
      fi
      ;;
    help) usage ;;
    *) die "Unknown action: ${action}" ;;
  esac
}

main "$@"
