#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Usage: $0 <Directory containing split APKs>"
    exit -1
fi

fulldir="$( cd $1 && pwd)"
debugKeystore="$fulldir/../debug.keystore"
if [ ! -z "$2" ]
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
i=0
for filename in $(ls $fulldir | sort )
do
	echo $f
	apktmpDir="$tmpDir/${filename}_unpack"

	# If base APK, insert network_security_config
	if [ $i -eq 0 ]; then

		# Unpack into its own directory
		java -jar "$DIR/apktool.jar" d -s -r --force-manifest -f -o $apktmpDir/ $fulldir/$filename

		if [ ! -d "$apktmpDir/res/xml" ]; then
			mkdir $apktmpDir/res/xml
		fi

		cp "$DIR/network_security_config.xml" $apktmpDir/res/xml/.
		if ! grep -q "networkSecurityConfig" $apktmpDir/AndroidManifest.xml; then
			sed -E "s/(<application.*)(>)/\1 android\:networkSecurityConfig=\"@xml\/network_security_config\" \2 /" $apktmpDir/AndroidManifest.xml > $apktmpDir/AndroidManifest.xml.new
			mv $apktmpDir/AndroidManifest.xml.new $apktmpDir/AndroidManifest.xml
		fi 
	else
		java -jar "$DIR/apktool.jar" d -s -r -f -o $apktmpDir/ $fulldir/$filename
	fi

	i=$(( i + 1 ))

	# from old script
	java -jar "$DIR/apktool.jar" empty-framework-dir --force
	# Pack dir into apk
	echo "Building new APK $filename"
	java -jar "$DIR/apktool.jar" b -o $fullNewDir/$filename $apktmpDir

	# Sign
	jarsigner -verbose -keystore $debugKeystore -storepass android -keypass android $fullNewDir/$filename androiddebugkey
done
