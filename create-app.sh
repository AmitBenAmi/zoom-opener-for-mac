#!/usr/bin/env bash

GREEN='\033[1;32m'
NC='\033[0m'

if [[ $# -lt 5 ]]; then
    YELLOW='\033[1;33m'
    WHITE='\033[1;37m'
    echo -e "${YELLOW}"'Not a valid command, not enough parameters passed. Usage:'
    echo -e "${WHITE}"'./create-app.sh "app-name" "bundle-identifier" /path/to/icon.icns "zoom-domain" "zoom-meeting-id" ["zoom-meeting-password"]'
    echo -e '\n'"${YELLOW}"'For Example:'
    echo -e "${WHITE}"'./create-app.sh "Open Zoom" "zoom.open.my-company.com" ~/my-icongs/zoom-icon.icns "us04web.zoom.us" "77950543638" ["password"]'"${NC}"
    exit 1
fi

APP_NAME=$1
BUNDLE_IDENTIFIER=$2
ICON_LOCATION=$3
ZOOM_DOMAIN=$4
ZOOM_MEETING_ID=$5
ZOOM_PASSWORD=""

if [[ -n $6 ]]; then
    ZOOM_PASSWORD='\&pwd='$5
fi

echo -e "${GREEN}"'Changing the startup script'"${NC}"
cp ./pkg-content/Contents/MacOS/app.sh ./app.sh.backup
sed -i '' 's|<zoom-domain>|'"${ZOOM_DOMAIN}"'|' ./pkg-content/Contents/MacOS/app.sh
sed -i '' 's|<meeting-id>|'"${ZOOM_MEETING_ID}${ZOOM_PASSWORD}"'|' ./pkg-content/Contents/MacOS/app.sh
mv ./pkg-content/Contents/MacOS/app.sh "./pkg-content/Contents/MacOS/${APP_NAME}.sh"

echo -e "${GREEN}"'Changing the icon'"${NC}"
mv ./pkg-content/Contents/Resources/icon.icns ./icon.icns.backup
cp "${ICON_LOCATION}" ./pkg-content/Contents/Resources/icon.icns

echo -e "${GREEN}"'Changing the Info.plist'"${NC}"
cp ./pkg-content/Contents/Info.plist ./Info.plist.backup
sed -i '' 's/<AppName>/'"${APP_NAME}"'/g' ./pkg-content/Contents/Info.plist
sed -i '' 's/<CFBundleIdentifier>/'"${BUNDLE_IDENTIFIER}"'/' ./pkg-content/Contents/Info.plist

echo -e "${GREEN}"'Packaging the app'"${NC}"
pkgbuild \
    --install-location "/Applications/${APP_NAME}.app" \
    --root ./pkg-content  \
    --identifier "${BUNDLE_IDENTIFIER}" \
    "./${APP_NAME}.pkg"

echo -e "${GREEN}"'Reverting all of the changes'"${NC}"
rm "./pkg-content/Contents/MacOS/${APP_NAME}.sh"
mv ./app.sh.backup ./pkg-content/Contents/MacOS/app.sh
mv ./icon.icns.backup ./pkg-content/Contents/Resources/icon.icns
mv ./Info.plist.backup ./pkg-content/Contents/Info.plist