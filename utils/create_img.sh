#!/bin/bash

export NAME="MenuPing"

echo "-----------------------------------------------"
echo "| Creating image for application distribution |"
echo "-----------------------------------------------"

echo ""
echo "Are you sure you did : "
echo "  - update every occurence of the version number in code and interface"
echo "  - launch build_and_sign"
echo ""
echo -n "Confirm (Y/n) "

read answer

if [ "$answer" = "n" ]; then
  exit 1
fi

echo "Creating working directory"
CUR_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
TEMP_VOL=$(mktemp)

if [ ! -d dist/${NAME}.app ]; then
  echo " --> You lied, you did not create build the app"
  exit 1
fi

if [ -f "${CUR_DIR}/dist/${NAME}.dmg" ]; then
  echo -n " --> Warning : target file dist/${NAME}.dmg already exists. Are you sure you want to overwrite ? (Y/n) "
  read answer

  if [ "$answer" = "n" ]; then
    exit 1
  else
    rm "${CUR_DIR}/dist/${NAME}.dmg"
  fi
fi

cp -a "dist/${NAME}.app" "${TEMP_DIR}"
cd "${TEMP_DIR}" || echo "Unable to cd to ${TEMP_DIR}" and exit 1
ln -s /Applications/ App
mv App " "

echo -n "Creating dmgfile. "
hdiutil create "${TEMP_VOL}.dmg" -ov -volname "${NAME}" -fs HFS+ -srcfolder "${CUR_DIR}/dist/${NAME}.app/" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error creating the dmgfile"
  exit 1
fi
echo "Done"

echo -n "Converting to application dmg. "
hdiutil convert "${TEMP_VOL}.dmg" -format UDZO -o "${CUR_DIR}/dist/${NAME}.dmg" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error in conversion"
  exit 1
fi
echo "Done"
