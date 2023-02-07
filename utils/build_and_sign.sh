#!/bin/bash

export IDENTITY="Developer ID Application: Julien Bordet (3HLJ4AW5AX)"
export NAME="MenuPing"
export YOUR_BUNDLE_ID="info.bordet.menuping"

echo "------------------------------------"
echo "| Building and codesigning the app |"
echo "------------------------------------"

echo "Checking pre-requisites"

if [[ "$VIRTUAL_ENV" == "" ]]; then
  echo " -> you should be in virtual env to build ${NAME}"
  exit 1
fi

echo "Building through py2app"
python3 setup.py py2app --arch universal2 >/dev/null 2>&1

echo "Signing librairies code"
cd dist

find "${NAME}.app" -iname '*.so' -or -iname '*.dylib' |
    while read libfile; do
        codesign --sign "${IDENTITY}" \
                 --entitlements ../resources/entitlements.plist \
                 --deep "${libfile}" \
                 --force \
                 --timestamp \
                 --options runtime >/dev/null 2>&1 ;
        if [ $? -ne 0 ]; then
            echo " -> error signing ${libfile}"
            exit 1
        fi
    done;

echo "Signing the bundle"
codesign --sign "${IDENTITY}" \
         --entitlements ../resources/entitlements.plist \
         --deep "${NAME}.app" \
         --force \
         --timestamp \
         --options runtime >/dev/null 2>&1 ;

if [ $? -ne 0 ]; then
    echo " -> error signing ${NAME}.app"
    exit 1
fi

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
# To investigate a notarization issue, retrieve the log file associated with the RequestUUID using the
# following command:
#
# xcrun altool --notarization-info <RequestUUID> -u zejames@gmail.com --password "@keychain:AC_PASSWORD"
#
# grep the output for "LogFileURL" and download the log file using the URL provided.

#
# Staple the App
#
echo "After notarization, you should staple the app, with"
echo "  # xcrun stapler staple " "dist/${NAME}.app"
