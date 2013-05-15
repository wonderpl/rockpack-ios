#!/bin/sh

FULL_VERSION=`git describe --match '[0-9]*'`
VERSION=`echo $FULL_VERSION | sed -e 's/-[^-]*$//' -e 'y/-/./'`
SHORT_VERSION=`echo $FULL_VERSION | sed 's/-.*$//'`

for plist in RockPack/*Info.plist; do
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" $plist
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $SHORT_VERSION" $plist
	/usr/libexec/PlistBuddy -c "Set :FullVersion $FULL_VERSION" $plist
done
