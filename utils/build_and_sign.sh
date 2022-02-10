#!/bin/bash

export IDENTITY="Developer ID Application: Julien Bordet (3HLJ4AW5AX)"
export NAME="MenuPing"
export YOUR_BUNDLE_ID="info.bordet.menuping"

echo "------------------------------------"
echo "| Building and codesigning the app |"
echo "------------------------------------"

echo "Building through py2app"
python3 setup.py py2app >/dev/null 2>&1

echo "Signing librairies code"
cd dist

find "${NAME}.app" -iname '*.so' -or -iname '*.dylib' |
    while read libfile; do
        codesign --sign "${IDENTITY}" \
                 --entitlements ../resources/entitlements.plist \
                 --deep "${libfile}" \
                 --force \
                 --timestamp \
                 --options runtime >/dev/null 2>&1;
    done;

echo "Signing the bundle"
codesign --sign "${IDENTITY}" \
         --entitlements ../resources/entitlements.plist \
         --deep "${NAME}.app" \
         --force \
         --timestamp \
         --options runtime >/dev/null 2>&1;

cd ..

#
# Creating archive for
#

echo "Creating archive"
ditto -c -k --keepParent "dist/${NAME}.app" dist/${NAME}.zip

#
# @keychain:AC_PASSWORD must have been inserte into keychain thanks to
# xcrun altool --store-password-in-keychain-item "AC_PASSWORD" -u "xxxx@gmail.com" -p "password"
#
# password must have been created in https://appleid.apple.com/account/manage / "App-Specific Passwords"
#

echo "Sending for notarization (can be a bit long)"
xcrun altool --notarize-app -t osx -f dist/${NAME}.zip --primary-bundle-id ${YOUR_BUNDLE_ID} \
          -u zejames@gmail.com --password "@keychain:AC_PASSWORD"

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
echo "After notarization, you should staple the app, with"
echo "  # xcrun stapler staple " "dist/${NAME}.app"