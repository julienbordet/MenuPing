#!/bin/bash

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
cur_dir=`pwd`
temp_dir=`mktemp -d`
temp_vol=`mktemp`

if [ ! -d dist/MenuPing.app ]; then
  echo " --> You lied, you did not create build the app"
  exit 1
fi

if [ -f $cur_dir"/dist/MenuPing.dmg" ]; then
  echo -n " --> Warning : target file dist/MenuPing.dmg already exists. Are you sure you want to overwrite ? (Y/n) "
  read answer

  if [ "$answer" = "n" ]; then
    exit 1
  else
    rm $cur_dir"/dist/MenuPing.dmg"
  fi
fi

cp -a dist/MenuPing.app $temp_dir
cd $temp_dir
ln -s /Applications/ Applications

echo -n "Creating dmgfile. "
hdiutil create $temp_vol.dmg -ov -volname "MenuPing" -fs HFS+ -srcfolder $cur_dir"/dist/MenuPing.app/" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error creating the dmgfile"
  exit 1
fi
echo "Done"

echo -n "Converting to application dmg. "
hdiutil convert $temp_vol.dmg -format UDZO -o $cur_dir"/dist/MenuPing.dmg" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Error in conversion"
  exit 1
fi
echo "Done"
