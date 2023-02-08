#!/bin/bash

echo "---------------------"
echo "| Building the app  |"
echo "---------------------"

echo "Checking pre-requisites"

if [[ "$VIRTUAL_ENV" == "" ]]; then
  echo " -> you should be in virtual env to build ${NAME}"
  exit 1
fi

echo "Building through py2app"
#python3 setup.py py2app --arch universal2 >/dev/null 2>&1
python3 setup.py py2app --arch universal2

if [ $? -ne 0 ]; then
    echo " -> error building ${NAME}"
    exit 1
fi
