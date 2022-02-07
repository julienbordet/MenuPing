#!/bin/bash

echo "-----------------------------------------------"
echo "| Creating image for application distribution |"
echo "-----------------------------------------------"

echo ""
echo "Are you sure you did :"
echo "  - Update every occurence of the version number in code and interface"
echo "  - Build the app through py2app"
echo ""
echo -n "Confirm (Y/n) "

read answer

if [ $answer != "Y" ]; then
  exit 1
fi

echo "Creating dmgfile"
hdiutil create /tmp/MenuPing.dmg -ov -volname "MenuPing" -fs HFS+ -srcfolder "/dist/"