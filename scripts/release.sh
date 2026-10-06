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
ASC_CLOUD_SIGNING="false"
ASC_SIGNING_ARGS=()

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
  scripts/release.sh upload-asc [target] [options]
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
  --asc-cloud-signing    Build ios/macos via xcodebuild cloud signing (for CI)
  --dry-run              Print commands without executing them
  --help                 Show this help

Server API upload environment variables:
  RELEASE_SERVER_API       API root (default: http://localhost:5046)
  RELEASE_SERVER_USERNAME  Login username
  RELEASE_SERVER_PASSWORD  Login password
  RELEASE_APP_ID           Application id from GET /api/App
  RELEASE_CHANNEL_ID       Channel id from GET /api/Channel
  RELEASE_ID               Release id shown to users (default: pubspec version)
  RELEASE_NAME             Release name (default: <platform> <version>)
  RELEASE_DESCRIPTION      Release description (optional)

App Store Connect environment variables:
  ASC_API_KEY_ID         App Store Connect API key ID
  ASC_ISSUER_ID          App Store Connect issuer ID
  ASC_API_KEY_PATH       Path to the .p8 private key file
  ASC_BUNDLE_TYPE        Override the altool --type value (ios or osx)
  ASC_TEAM_ID            Apple team id (default: read from the Xcode project)

upload-asc targets:
  ios                    Upload the .ipa (default)
  macos                  Upload the .pkg produced by an App Store export

Examples:
  scripts/release.sh build android-aab --channel appstore
  scripts/release.sh release ios --output-dir ./dist
  RELEASE_SERVER_USERNAME=root RELEASE_SERVER_PASSWORD='***' \
    RELEASE_APP_ID=... RELEASE_CHANNEL_ID=... \
    scripts/release.sh upload-server
  ASC_API_KEY_ID=ABC ASC_ISSUER_ID=... ASC_API_KEY_PATH=./private/AuthKey_ABC.p8 \
    scripts/release.sh upload-asc ios

  ASC_API_KEY_ID=ABC ASC_ISSUER_ID=... ASC_API_KEY_PATH=./private/AuthKey_ABC.p8 \
    scripts/release.sh build ios --asc-cloud-signing --channel appstore
EOF
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

flutter_args=(--no-tree-shake-icons "--dart-define=UPDATE_CHANNEL=${UPDATE_CHANNEL}")

require_asc_key() {
  [[ -n "${ASC_API_KEY_ID:-}" ]] || die "Set ASC_API_KEY_ID before using --asc-cloud-signing"
  [[ -n "${ASC_ISSUER_ID:-}" ]] || die "Set ASC_ISSUER_ID before using --asc-cloud-signing"
  [[ -n "${ASC_API_KEY_PATH:-}" ]] || die "Set ASC_API_KEY_PATH before using --asc-cloud-signing"
  [[ -f "${ASC_API_KEY_PATH}" ]] || die "ASC API key file not found: ${ASC_API_KEY_PATH}"
  ASC_SIGNING_ARGS=(
    -allowProvisioningUpdates
    -authenticationKeyPath "$(cd "$(dirname "${ASC_API_KEY_PATH}")" && pwd)/$(basename "${ASC_API_KEY_PATH}")"
    -authenticationKeyID "${ASC_API_KEY_ID}"
    -authenticationKeyIssuerID "${ASC_ISSUER_ID}"
  )
}

apple_team_id() {
  local platform_dir="$1" team="${ASC_TEAM_ID:-}"
  if [[ -z "${team}" ]]; then
    team="$(sed -n 's/.*DEVELOPMENT_TEAM = \([A-Za-z0-9]*\);.*/\1/p' "${PROJECT_ROOT}/${platform_dir}/Runner.xcodeproj/project.pbxproj" | head -1)"
  fi
  [[ -n "${team}" ]] || die "Could not determine the Apple team id, set ASC_TEAM_ID"
  printf '%s' "${team}"
}

write_export_options() {
  local plist="$1" team="$2"
  cat > "${plist}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>teamID</key>
	<string>${team}</string>
	<key>destination</key>
	<string>export</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
PLIST
}

# Cloud signing: xcodebuild asks App Store Connect to create or refresh the
# certificates and provisioning profiles from the API key, so CI only needs the
# .p8. flutter build ipa cannot pass the -authenticationKey* flags through, which
# is why the archive is driven by xcodebuild directly.
build_apple_cloud_signed() {
  local target="$1"
  local platform_dir="${target}"
  local workspace="${platform_dir}/Runner.xcworkspace"
  local archive_path="${PROJECT_ROOT}/build/${platform_dir}/Runner.xcarchive"
  local export_dir="${PROJECT_ROOT}/build/${platform_dir}/asc-export"
  local options_plist="${PROJECT_ROOT}/build/${platform_dir}/ExportOptions.plist"
  local destination

  [[ "$(uname -s)" == "Darwin" ]] || die "${target} builds require macOS and Xcode"
  require_command flutter
  require_command xcodebuild
  require_asc_key

  if [[ "${target}" == "ios" ]]; then
    destination="generic/platform=iOS"
  else
    destination="generic/platform=macOS"
  fi

  # --config-only still runs pod install and writes Generated.xcconfig; the
  # archive below performs the actual build, including the Dart AOT step.
  run flutter build "${target}" --release --config-only "${flutter_args[@]}"

  mkdir -p "$(dirname "${archive_path}")"
  write_export_options "${options_plist}" "$(apple_team_id "${platform_dir}")"
  run xcodebuild -workspace "${workspace}" -scheme Runner -configuration Release \
    -destination "${destination}" -archivePath "${archive_path}" \
    archive "${ASC_SIGNING_ARGS[@]}"

  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -rf "${export_dir}"
    mkdir -p "${export_dir}"
  fi
  run xcodebuild -exportArchive -archivePath "${archive_path}" \
    -exportOptionsPlist "${options_plist}" -exportPath "${export_dir}" \
    "${ASC_SIGNING_ARGS[@]}"

  if [[ "${DRY_RUN}" == "true" ]]; then
    printf '+ copy %s artifact from %q to %q\n' "${target}" "${export_dir}" "${OUTPUT_DIR}"
    return 0
  fi

  local artifact
  if [[ "${target}" == "ios" ]]; then
    artifact="$(find "${export_dir}" -type f -name '*.ipa' -print -quit)"
    [[ -n "${artifact}" ]] || die "No .ipa produced in ${export_dir}"
    cp "${artifact}" "${OUTPUT_DIR}/"
  else
    # An App Store export for macOS emits a signed .pkg; keep an ASCII name for CI.
    artifact="$(find "${export_dir}" -type f -name '*.pkg' -print -quit)"
    [[ -n "${artifact}" ]] || die "No .pkg produced in ${export_dir}"
    cp "${artifact}" "${OUTPUT_DIR}/ios_club_app-macos.pkg"
  fi
  log "Exported $(basename "${artifact}")"
}

build_target() {
  local target="$1"
  mkdir -p "${OUTPUT_DIR}"

  if [[ "${ASC_CLOUD_SIGNING}" == "true" && ( "${target}" == "ios" || "${target}" == "macos" ) ]]; then
    build_apple_cloud_signed "${target}"
    log "Built ${target} artifacts in ${OUTPUT_DIR}"
    return 0
  fi

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
      # The bundle is named after PRODUCT_NAME (macos/Runner/Configs/AppInfo.xcconfig),
      # so look it up instead of assuming a fixed file name.
      local app_path
      app_path="$(find "${PROJECT_ROOT}/build/macos/Build/Products/Release" -maxdepth 1 -type d -name '*.app' -print -quit 2>/dev/null)"
      if [[ "${DRY_RUN}" == "true" ]]; then
        printf '+ zip -qry %q %q\n' "${OUTPUT_DIR}/ios_club_app-macos.zip" "${app_path:-<product>.app}"
      else
        [[ -n "${app_path}" ]] || die "macOS app bundle not found under build/macos/Build/Products/Release"
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
  local api="${RELEASE_SERVER_API:-http://localhost:5046}"
  local username="${RELEASE_SERVER_USERNAME:-}"
  local password="${RELEASE_SERVER_PASSWORD:-}"
  [[ -n "${username}" ]] || die "Set RELEASE_SERVER_USERNAME before uploading"
  [[ -n "${password}" ]] || die "Set RELEASE_SERVER_PASSWORD before uploading"
  [[ -n "${RELEASE_APP_ID:-}" ]] || die "Set RELEASE_APP_ID before uploading"
  [[ -n "${RELEASE_CHANNEL_ID:-}" ]] || die "Set RELEASE_CHANNEL_ID before uploading"
  local files=()
  while IFS= read -r -d '' file; do files+=("${file}"); done < <(find "${OUTPUT_DIR}" -maxdepth 1 -type f -print0)
  ((${#files[@]} > 0)) || die "No artifacts found in ${OUTPUT_DIR}; run build first"
  require_command curl
  require_command jq

  local release_id="${RELEASE_ID:-}"
  if [[ -z "${release_id}" ]]; then
    release_id="$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\).*/\1/p' "${PROJECT_ROOT}/pubspec.yaml" | head -1)"
  fi
  [[ -n "${release_id}" ]] || die "Set RELEASE_ID or add a version to pubspec.yaml"
  local release_name="${RELEASE_NAME:-}"
  [[ -n "${release_name}" ]] || release_name="${release_id}"

  if [[ "${DRY_RUN}" == "true" ]]; then
    printf '+ POST %s/api/Auth/login (credentials redacted)\n' "${api%/}"
    printf '+ POST %s/api/Release (appId=%q releaseId=%q)\n' "${api%/}" "${RELEASE_APP_ID}" "${release_id}"
    printf '+ POST %s/api/Soft/upload for %d artifact(s) (channelId=%q)\n' "${api%/}" "${#files[@]}" "${RELEASE_CHANNEL_ID}"
    return 0
  fi

  local login_json token release_json release_db_id file platform upload_name
  login_json="$(curl -fsS "${api%/}/api/Auth/login" \
    -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg username "${username}" --arg password "${password}" '{username:$username,password:$password}')")"
  token="$(jq -r '.token // empty' <<<"${login_json}")"
  [[ -n "${token}" && "${token}" != "null" ]] || die "Server login failed"

  release_json="$(curl -fsS "${api%/}/api/Release" -X POST \
    -H "Authorization: Bearer ${token}" -H 'Content-Type: application/json' \
    -d "$(jq -nc --arg name "${release_name}" --arg description "${RELEASE_DESCRIPTION:-}" \
      --arg releaseId "${release_id}" --arg appId "${RELEASE_APP_ID}" \
      '{name:$name,description:$description,releaseId:$releaseId,appId:$appId}')")"
  release_db_id="$(jq -r '.id // empty' <<<"${release_json}")"
  [[ -n "${release_db_id}" && "${release_db_id}" != "null" ]] || die "Server did not return a release id"

  for file in "${files[@]}"; do
    platform="$(basename "${file}")"
    upload_name="${RELEASE_UPLOAD_NAME_PREFIX:-Downloader} ${platform}"
    curl -fsS "${api%/}/api/Soft/upload" -X POST \
      -H "Authorization: Bearer ${token}" \
      -F "name=${upload_name}" \
      -F "description=${RELEASE_SOFT_DESCRIPTION:-${platform}}" \
      -F "releaseId=${release_db_id}" \
      -F "channelId=${RELEASE_CHANNEL_ID}" \
      -F "file=@${file}" | jq .
  done
  log "Uploaded ${#files[@]} artifact(s) to ${api%/}"
}

upload_asc() {
  local target="${1:-ios}" pattern bundle_type artifact
  case "${target}" in
    ios) pattern='*.ipa'; bundle_type='ios' ;;
    macos) pattern='*.pkg'; bundle_type='osx' ;;
    *) die "upload-asc supports ios or macos, got: ${target}" ;;
  esac

  [[ -n "${ASC_API_KEY_ID:-}" ]] || die "Set ASC_API_KEY_ID before uploading"
  [[ -n "${ASC_ISSUER_ID:-}" ]] || die "Set ASC_ISSUER_ID before uploading"
  [[ -n "${ASC_API_KEY_PATH:-}" ]] || die "Set ASC_API_KEY_PATH before uploading"
  [[ -f "${ASC_API_KEY_PATH}" ]] || die "ASC API key file not found: ${ASC_API_KEY_PATH}"
  require_command xcrun
  artifact="$(find "${OUTPUT_DIR}" -maxdepth 1 -type f -name "${pattern}" -print -quit)"
  [[ -n "${artifact}" ]] || die "No ${pattern} artifact found in ${OUTPUT_DIR}; build ${target} first"
  # altool discovers AuthKey_<ID>.p8 from a fixed private_keys directory.
  # Use a temporary directory so callers can keep keys anywhere on disk.
  local auth_dir key_name
  auth_dir="$(mktemp -d "${TMPDIR:-/tmp}/ios-club-asc.XXXXXX")"
  key_name="AuthKey_${ASC_API_KEY_ID}.p8"
  mkdir -p "${auth_dir}/private_keys"
  ln -s "$(cd "$(dirname "${ASC_API_KEY_PATH}")" && pwd)/$(basename "${ASC_API_KEY_PATH}")" "${auth_dir}/private_keys/${key_name}"
  local upload_status=0
  (cd "${auth_dir}" && run xcrun altool --upload-app --type "${ASC_BUNDLE_TYPE:-${bundle_type}}" --file "${artifact}" \
    --api-key "${ASC_API_KEY_ID}" --api-issuer "${ASC_ISSUER_ID}") || upload_status=$?
  rm -rf "${auth_dir}"
  ((upload_status == 0)) || return "${upload_status}"
  log "Uploaded ${artifact} to App Store Connect"
}

parse_options() {
  while (($#)); do
    case "$1" in
      --output-dir) (($# >= 2)) || die "--output-dir requires a value"; OUTPUT_DIR="$2"; shift 2 ;;
      --channel) (($# >= 2)) || die "--channel requires a value"; UPDATE_CHANNEL="$2"; flutter_args=(--no-tree-shake-icons "--dart-define=UPDATE_CHANNEL=${UPDATE_CHANNEL}"); shift 2 ;;
      --skip-clean) SKIP_CLEAN="true"; shift ;;
      --asc-cloud-signing) ASC_CLOUD_SIGNING="true"; shift ;;
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
  elif [[ "${action}" == "upload-asc" && $# -gt 0 && "$1" != -* ]]; then
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
    upload-asc) upload_asc "${target:-ios}" ;;
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
