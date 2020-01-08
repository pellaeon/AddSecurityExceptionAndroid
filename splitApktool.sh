#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Usage: $0 <build|decode> <Directory containing split APKs>"
    exit -1
fi

fulldir="$( cd $2 && pwd)"
debugKeystore="$fulldir/../debug.keystore"
if [ ! -z "$3" ]
	then
		debugKeystore=$2
	else
    if [ ! -f $debugKeystore ]; then
      echo "No debug keystore was found, creating new one..."
      keytool -genkey -v -keystore $debugKeystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
    fi
fi

apkdirname=$(basename "$fulldir")
new="_new"
tmpDir="${fulldir}_tmp"
mkdir -p $tmpDir

#extension="${filename##*.}"
#filename="${filename%.*}"
#new="_new.apk"
fullNewDir="${fulldir}_new"
mkdir -p $fullNewDir

# For each APK. sort will make sure shortest filename is first, shortest is the base apk
for filename in $(ls $fulldir | sort )
do
	echo $f
	apktmpDir="$tmpDir/${filename}_unpack"

	if [ $1 = 'decode' ]; then
		java -jar "$DIR/apktool.jar" d -s -r -f -o $apktmpDir/ $fulldir/$filename
	elif [ $1 = 'build' ]; then
		echo "Building new APK $filename"
		# Pack dir into apk
		java -jar "$DIR/apktool.jar" b -o $fullNewDir/$filename $apktmpDir

		echo "Signing..."
		jarsigner -verbose -keystore $debugKeystore -storepass android -keypass android $fullNewDir/$filename androiddebugkey
	fi

	# from old script
	#java -jar "$DIR/apktool.jar" empty-framework-dir --force
done
