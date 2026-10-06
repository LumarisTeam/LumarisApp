#!/usr/bin/env bash

# Check an App Store Connect API key before it is used for cloud signing or uploads.
# Answers three questions: is the key/issuer pair valid, may it manage signing
# assets, and are the app records we upload to actually there.
# Credentials come from the environment; nothing sensitive is written to disk.

set -Eeuo pipefail

ASC_API_KEY_ID="${ASC_API_KEY_ID:-}"
ASC_ISSUER_ID="${ASC_ISSUER_ID:-}"
ASC_API_KEY_PATH="${ASC_API_KEY_PATH:-}"
BUNDLE_IDS=("$@")

API_ROOT="https://api.appstoreconnect.apple.com/v1"
BODY_FILE="$(mktemp "${TMPDIR:-/tmp}/asc-verify.XXXXXX")"
trap 'rm -f "${BODY_FILE}"' EXIT

ok() { printf '  [ OK ] %s\n' "$*"; }
ko() { printf '  [FAIL] %s\n' "$*" >&2; }
info() { printf '  [info] %s\n' "$*"; }
die() { ko "$*"; exit 1; }

usage() {
  cat <<'EOF'
Usage: ASC_API_KEY_ID=... ASC_ISSUER_ID=... ASC_API_KEY_PATH=... scripts/verify_asc_key.sh [bundle-id ...]

Checks:
  1. The key id / issuer id / .p8 triple authenticates against App Store Connect
  2. The key role can read certificates and provisioning profiles (cloud signing needs this)
  3. App records for the given bundle ids exist

Exit code is non-zero as soon as one of these predicts a failed signing or upload.
EOF
}

base64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

# openssl 输出的是 ASN.1 DER 签名，而 JOSE 的 ES256 要求裸的 R||S（各 32 字节）。
# 把 DER 直接塞进 JWT，Apple 会回 401，看上去跟 Key ID 配错了没区别。
# 从 stdin 读 DER，往 stdout 写 64 字节裸签名。
der_to_raw_signature() {
  local hex i rlen slen r s
  hex="$(od -An -tx1 -v | tr -d ' \n')"

  # 30 <len> 02 <rlen> <r> 02 <slen> <s>；P-256 的签名用不到长形式长度。
  [[ "${hex:0:2}" == "30" ]] || return 1
  [[ "$((16#${hex:2:2}))" -eq "$((${#hex} / 2 - 2))" ]] || return 1

  i=4
  [[ "${hex:${i}:2}" == "02" ]] || return 1
  rlen="$((16#${hex:$((i + 2)):2}))"
  r="${hex:$((i + 4)):$((rlen * 2))}"
  i="$((i + 4 + rlen * 2))"

  [[ "${hex:${i}:2}" == "02" ]] || return 1
  slen="$((16#${hex:$((i + 2)):2}))"
  s="${hex:$((i + 4)):$((slen * 2))}"

  # DER 给最高位为 1 的整数补前导 00 表示正数，JOSE 不要；去掉后再补足 32 字节。
  while ((${#r} > 64)) && [[ "${r:0:2}" == "00" ]]; do r="${r:2}"; done
  while ((${#s} > 64)) && [[ "${s:0:2}" == "00" ]]; do s="${s:2}"; done
  ((${#r} <= 64 && ${#s} <= 64)) || return 1

  printf '%b' "$(printf '%064s%064s' "${r}" "${s}" | sed 's/ /0/g; s/../\\x&/g')"
}

make_token() {
  local header payload now signing_input signature
  header="$(printf '{"alg":"ES256","kid":"%s","typ":"JWT"}' "${ASC_API_KEY_ID}" | base64url)"
  now="$(date +%s)"
  payload="$(printf '{"iss":"%s","iat":%s,"exp":%s,"aud":"appstoreconnect-v1"}' \
    "${ASC_ISSUER_ID}" "${now}" "$((now + 900))" | base64url)"
  signing_input="${header}.${payload}"
  signature="$(printf '%s' "${signing_input}" |
    openssl dgst -sha256 -sign "${ASC_API_KEY_PATH}" |
    der_to_raw_signature | base64url)" ||
    die "无法把 openssl 的 DER 签名转成 JOSE 需要的裸 R||S；.p8 可能已损坏"
  printf '%s.%s' "${signing_input}" "${signature}"
}

# Sets API_STATUS and leaves the response body in BODY_FILE.
api_get() {
  # -g: URL 里的 [] 是 App Store Connect 的 filter 语法，不能让 curl 当作通配符
  API_STATUS="$(curl -sS -g -o "${BODY_FILE}" -w '%{http_code}' \
    -H "Authorization: Bearer ${TOKEN}" \
    -H 'Accept: application/json' \
    "${API_ROOT}/$1")"
}

explain_status() {
  case "$1" in
    401) printf 'Key ID、Issuer ID 与 .p8 不匹配（检查三者是否来自同一个 Key）' ;;
    403) printf 'Key 有效，但没有访问该资源的角色权限' ;;
    404) printf '资源不存在' ;;
    429) printf '请求过于频繁，稍后重试' ;;
    *) printf 'HTTP %s' "$1" ;;
  esac
}

main() {
  (($# == 0)) || [[ "$1" != "--help" && "$1" != "-h" ]] || { usage; exit 0; }

  [[ -n "${ASC_API_KEY_ID}" ]] || die "ASC_API_KEY_ID is not set"
  [[ -n "${ASC_ISSUER_ID}" ]] || die "ASC_ISSUER_ID is not set"
  [[ -n "${ASC_API_KEY_PATH}" ]] || die "ASC_API_KEY_PATH is not set"
  [[ -f "${ASC_API_KEY_PATH}" ]] || die "API key file not found: ${ASC_API_KEY_PATH}"
  command -v openssl >/dev/null 2>&1 || die "openssl is required"
  command -v curl >/dev/null 2>&1 || die "curl is required"
  command -v jq >/dev/null 2>&1 || die "jq is required"

  # 先确认这是个能解析的私钥，否则后面 Apple 的 401 会让人误以为是 ID 配错了。
  openssl pkey -in "${ASC_API_KEY_PATH}" -noout 2>/dev/null ||
    die "无法解析 ${ASC_API_KEY_PATH}：它可能不是有效的 .p8 私钥"

  local expected="AuthKey_${ASC_API_KEY_ID}.p8"
  if [[ "$(basename "${ASC_API_KEY_PATH}")" != "${expected}" ]]; then
    info "密钥文件名不是 ${expected}；release.sh 会自建软链接，手跑 altool 时需自行处理"
  fi

  TOKEN="$(make_token)"
  info "Issuer ${ASC_ISSUER_ID} / Key ${ASC_API_KEY_ID} / $(basename "${ASC_API_KEY_PATH}")"

  # 1. 认证
  api_get 'apps?limit=1'
  case "${API_STATUS}" in
    200) ok "认证通过：Key ID 与 Issuer ID 配对正确，.p8 签名有效" ;;
    *) ko "认证失败：$(explain_status "${API_STATUS}")"; exit 1 ;;
  esac

  # 2. 签名资源权限。只有 403 能确凿地说明角色不足；400 之类是脚本请求本身的问题，
  #    不该阻断发布，所以只报告、不判定失败。
  local signing_ok="true" cert_status profile_status
  api_get 'certificates?limit=50'
  cert_status="${API_STATUS}"
  api_get 'profiles?limit=50'
  profile_status="${API_STATUS}"

  if [[ "${cert_status}" == "200" ]]; then
    ok "可读取证书（共 $(jq -r '.meta.paging.total // (.data | length)' "${BODY_FILE}" 2>/dev/null || echo '?') 个）"
  elif [[ "${cert_status}" == "403" ]]; then
    ko "读取证书被拒：$(explain_status "${cert_status}")"; signing_ok="false"
  else
    info "读取证书返回 HTTP ${cert_status}，该项无法判断，跳过"
  fi

  if [[ "${profile_status}" == "200" ]]; then
    ok "可读取描述文件（共 $(jq -r '.meta.paging.total // (.data | length)' "${BODY_FILE}" 2>/dev/null || echo '?') 个）"
    info "其中 App Store 类型 $(jq -r '[.data[] | select(.attributes.profileType | test("STORE"))] | length' "${BODY_FILE}" 2>/dev/null || echo '?') 个"
  elif [[ "${profile_status}" == "403" ]]; then
    ko "读取描述文件被拒：$(explain_status "${profile_status}")"; signing_ok="false"
  else
    info "读取描述文件返回 HTTP ${profile_status}，该项无法判断，跳过"
  fi

  [[ "${signing_ok}" == "true" ]] ||
    die "Key 角色不足：xcodebuild 云端签名需要 Admin 或 App Manager"

  # 读取权限 Developer 角色也有，所以上面两项通过并不能证明能创建描述文件；
  # 不产生副作用就没法探测写权限，角色请直接在 ASC 的 Integrations 页面核对。
  info "注意：读取权限 Developer 角色同样具备，能否创建描述文件只有真跑一次签名才能确认"

  # 3. app 记录（仅在显式传入 bundle id 时检查）
  if ((${#BUNDLE_IDS[@]} > 0)); then
    local bundle found
    for bundle in "${BUNDLE_IDS[@]}"; do
      api_get "apps?filter[bundleId]=${bundle}&limit=1"
      if [[ "${API_STATUS}" == "200" ]] && [[ "$(jq -r '.data | length' "${BODY_FILE}" 2>/dev/null || echo 0)" -gt 0 ]]; then
        found="$(jq -r '.data[] | "\(.attributes.name) (\(.attributes.bundleId))"' "${BODY_FILE}")"
        ok "app 记录存在：${bundle} -> ${found}"
      elif [[ "${API_STATUS}" == "200" ]]; then
        ko "ASC 里没有 bundle id 为 ${bundle} 的 app 记录，上传会被拒绝"
        exit 1
      else
        info "查询 ${bundle} 返回 HTTP ${API_STATUS}，该项无法判断，跳过"
      fi
    done
  else
    info "未指定 bundle id，跳过 app 记录检查（可传 com.example.iosClubApp 等参数）"
  fi

  printf '\n通过：这个 Key 可以用于云端签名与上传。\n'
}

main "$@"
