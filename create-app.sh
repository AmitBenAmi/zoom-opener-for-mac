#!/usr/bin/env bash

if [[ $# -ne 4 ]];
then
    YELLOW="\033[1;33m"
    WHITE="\033[1;37m"
    NC="\033[0m"
    echo -e "${YELLOW}Not a valid command, not enough parameters passed. Usage:"
    echo -e "${WHITE}./create-app.sh \"app-name\" bundle-identifier zoom-url \"/path/to/icon.icns\""
    echo -e "\n${YELLOW}For Example:"
    echo -e "${WHITE}./create-app.sh \"Open Zoom\" zoom.open.my-company.com https://us04web.zoom.us/j/77950543638 \"~/my-icongs/zoom-icon.icns\"${NC}"
    exit 1
fi

APP_NAME=$1
BUNDLE_IDENTIFIER=$2
ZOOM_URL=$(echo $3 | sed -E 's/(http|https):\/\///')
ICON_LOCATION=$4

echo "Changing the startup script"
cp ./Contents/MacOS/app.sh ./app.sh.backup
sed -i 's/<url-for-zoom>/$ZOOM_URL/' ./Contents/MacOS/app.sh
mv ./Contents/MacOS/app.sh ./Contents/MacOS/$APP_NAME.sh

echo "Changing the icon"
mv ./Contents/Resources/icon.icns ./icon.icns.backup
mv $ICON_LOCATION ./Contents/Resources/icon.icns

echo "Changing the Info.plist"
cp ./Contents/Info.plist ./Info.plist.backup
sed -i 's/<AppName>/$APP_NAME/g' ./Contents/Info.plist
sed -i 's/<CFBundleIdentifier>/$BUNDLE_IDENTIFIER/' ./Contents/Info.plist

echo "Packaging the app"
pkgbuild \
    --install-location /Applications/$APP_NAME.app \
    --root .  \
    --identifier $BUNDLE_IDENTIFIER \
    ./$APP_NAME.pkg

echo "Reverting all of the changes"
rm ./Contents/MacOS/$APP_NAME.sh
mv ./app.sh.backup ./Contents/MacOS/app.sh
mv ./icon.icns.backup ./Contents/Resources/icon.icns
mv ./Info.plist.backup ./Contents/Info.plist