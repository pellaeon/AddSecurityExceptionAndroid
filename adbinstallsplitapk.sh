#!/bin/bash

# $1 should be an directory containing the base and split APKs
dir=$( cd $1 && pwd )
dir_name=$(basename $dir)
adb push $dir /data/local/tmp/

session=$(adb shell pm install-create | egrep -o '[0-9]+')

for filename in $(ls $dir | sort )
do
	adb shell pm install-write $session $filename /data/local/tmp/$dir_name/$filename
done

adb shell pm install-commit $session
