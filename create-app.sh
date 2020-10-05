#!/usr/bin/env bash

GREEN='\033[1;32m'
NC='\033[0m'

if [[ $# -ne 4 ]];
then
    YELLOW='\033[1;33m'
    WHITE='\033[1;37m'
    echo -e "${YELLOW}"'Not a valid command, not enough parameters passed. Usage:'
    echo -e "${WHITE}"'./create-app.sh "app-name" "bundle-identifier" "zoom-url" /path/to/icon.icns'
    echo -e '\n'"${YELLOW}"'For Example:'
    echo -e "${WHITE}"'./create-app.sh "Open Zoom" "zoom.open.my-company.com" "https://us04web.zoom.us/j/77950543638" ~/my-icongs/zoom-icon.icns'"${NC}"
    exit 1
fi

APP_NAME=$1
BUNDLE_IDENTIFIER=$2
ZOOM_URL=$(echo $3 | sed -E 's/(http|https):\/\///')
ICON_LOCATION=$4

echo -e "${GREEN}"'Changing the startup script'"${NC}"
cp ./pkg-content/Contents/MacOS/app.sh ./app.sh.backup
sed -i '' 's/<url-for-zoom>/$ZOOM_URL/' ./pkg-content/Contents/MacOS/app.sh
mv ./pkg-content/Contents/MacOS/app.sh "./pkg-content/Contents/MacOS/${APP_NAME}.sh"

echo -e "${GREEN}"'Changing the icon'"${NC}"
mv ./pkg-content/Contents/Resources/icon.icns ./icon.icns.backup
cp "${ICON_LOCATION}" ./pkg-content/Contents/Resources/icon.icns

echo -e "${GREEN}"'Changing the Info.plist'"${NC}"
cp ./pkg-content/Contents/Info.plist ./Info.plist.backup
sed -i '' 's/<AppName>/$APP_NAME/g' ./pkg-content/Contents/Info.plist
sed -i '' 's/<CFBundleIdentifier>/$BUNDLE_IDENTIFIER/' ./pkg-content/Contents/Info.plist

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