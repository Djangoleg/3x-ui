#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env not found: $ENV_FILE" >&2
    exit 1
fi

set -a
. "$ENV_FILE"
set +a

echo "SOCKS_PROXY:" ${SOCKS_PROXY}
CURL_OPTS=(
  --proxy "${SOCKS_PROXY}"
  --connect-timeout 20
  --retry 3
  --retry-delay 3
  -L
)

case "$(uname -m)" in
    amd64)
        ARCH="64"
        FNAME="amd64"
        MTG_ARCH="amd64"
        ;;
    i386)
        ARCH="32"
        FNAME="i386"
        MTG_ARCH="386"
        ;;
    armv8 | arm64 | aarch64)
        ARCH="arm64-v8a"
        FNAME="arm64"
        MTG_ARCH="arm64"
        ;;
    armv7 | arm | arm32)
        ARCH="arm32-v7a"
        FNAME="arm32"
        MTG_ARCH="armv7"
        ;;
    armv6)
        ARCH="arm32-v6"
        FNAME="armv6"
        MTG_ARCH="armv6"
        ;;
    *)
        ARCH="64"
        FNAME="amd64"
        MTG_ARCH="amd64"
        ;;
esac
MTG_VER="2.2.8"

mkdir -p bin
cd bin
find . ! -name 'config.json' -type f -exec rm -f {} +

XRAY_URL="https://github.com/XTLS/Xray-core/releases/download/v26.7.11/Xray-macos-${ARCH}.zip"
echo ${XRAY_URL}
curl "${CURL_OPTS[@]}" -O "${XRAY_URL}"

unzip "Xray-macos-${ARCH}.zip"
rm -f "Xray-macos-${ARCH}.zip" geoip.dat geosite.dat
mv xray "xray-darwin-${FNAME}"

MTG_URL="https://github.com/9seconds/mtg/releases/download/v${MTG_VER}/mtg-${MTG_VER}-darwin-${MTG_ARCH}.tar.gz"
echo ${MTG_URL}
curl "${CURL_OPTS[@]}" -O "${MTG_URL}"

tar -xzf "mtg-${MTG_VER}-darwin-${MTG_ARCH}.tar.gz"
mv "mtg-${MTG_VER}-darwin-${MTG_ARCH}/mtg" "mtg-darwin-${FNAME}" 2>/dev/null || mv mtg "mtg-darwin-${FNAME}"
rm -rf "mtg-${MTG_VER}-darwin-${MTG_ARCH}" "mtg-${MTG_VER}-darwin-${MTG_ARCH}.tar.gz"
chmod +x "mtg-darwin-${FNAME}"

GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

GEOIP_IR_URL="https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geoip.dat"
GEOSITE_IR_URL="https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geosite.dat"

GEOIP_RU_URL="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_RU_URL="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat"

echo "${GEOIP_URL}"
curl "${CURL_OPTS[@]}" -O "${GEOIP_URL}"

echo "${GEOSITE_URL}"
curl "${CURL_OPTS[@]}" -O "${GEOSITE_URL}"

echo "${GEOIP_IR_URL}"
curl "${CURL_OPTS[@]}" -o geoip_IR.dat "${GEOIP_IR_URL}"

echo "${GEOSITE_IR_URL}"
curl "${CURL_OPTS[@]}" -o geosite_IR.dat "${GEOSITE_IR_URL}"

echo "${GEOIP_RU_URL}"
curl "${CURL_OPTS[@]}" -o geoip_RU.dat "${GEOIP_RU_URL}"

echo "${GEOSITE_RU_URL}"
curl "${CURL_OPTS[@]}" -o geosite_RU.dat "${GEOSITE_RU_URL}"

cd ../
