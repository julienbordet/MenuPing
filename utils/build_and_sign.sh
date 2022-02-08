#!/bin/bash

echo "------------------------------------"
echo "| Building and codesigning the app |
echo "------------------------------------"

echo "Building through py2app"
python3 setup.py py2app

echo "Signing code"
cd dist
codesign -v --deep --timestamp --entitlements ../resources/entitlements.plist  -o runtime -f -s "Developer ID Application: Julien Bordet (3HLJ4AW5AX)" MenuPing.app

#
# Creating archive for
#

echo "Creating archive"
ditto -c -k --keepParent "MenuPing.app" MenuPing.zip

#
# @keychain:AC_PASSWORD must have been inserte into keychain thanks to
# xcrun altool --store-password-in-keychain-item "AC_PASSWORD" -u "xxxx@gmail.com" -p "password"
#
# password must have been created in https://appleid.apple.com/account/manage / "App-Specific Passwords"
#

echo "Sending for notarization"
xcrun altool --notarize-app -t osx -f MenuPing.zip --primary-bundle-id info.bordet.menuping -u zejames@gmail.com --password "@keychain:AC_PASSWORD"
cd ..

echo "You should check the notarization result before creating the image for distribution"

#
# Notarization logs can be showed by
#
# xcrun altool --notarization-history 0 -u zejames@gmail.com --password "@keychain:AC_PASSWORD"
# or
# xcrun altool --verbose --notarization-history 0 -u zejames@gmail.com --password "@keychain:AC_PASSWORD"
#
#
# Staple the App
# xcrun stapler staple "dist/MenuPing.app"
#