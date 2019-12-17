# Add Security Exception to APK

In Android 7.0, Google introduced changes to the way user Certificate Authorities (CA) are trusted. These changes prevent third-parties from listening to network requests coming out of the application:
More info: 
1) https://developer.android.com/training/articles/security-config.html
2) http://android-developers.blogspot.com/2016/07/changes-to-trusted-certificate.html

The script `addSecurityExceptions.sh` injects into the APK network security exceptions that allow third-party software like Charles Proxy/Fiddler to listen to the network requests and responses of some Android applications.

## Getting Started

Download the script and the XML file and place them in the same directory.

### Prerequisites
APKTOOL is not needed anymore.

~~You will need `apktool` and the Android SDK installed~~

~~I recommend using `brew` on Mac to install `apktool`:~~

~~```brew install apktool```~~

## Usage

The script take two arguments: 
1) APK file path.
2) keystore file path (**optional** - Default is: ~/.android/debug.keystore )

### Examples

```
./addSecurityExceptions.sh myApp.apk

or

./addSecurityExceptions.sh myApp.apk ~/.android/debug.keystore

```

## Handling Split APKs

Google introduced "split APKs" to reduce the size of APK downloads. A device will only download:

- base APK
- native library according to the device's architecture
- language packs according to the device settings
- suitable resolution of resource packs (images) according to the device's screen

So when unpacking and packing the app, there are multiple APKs to handle, also during installation.

Note: split apks also mean that if you want to work on apks downloaded from third-party sites like apkpure.com and apkmirror, it sometimes will not install on your device because the downloaded apk does not contain packs that your device needs.

In order to download correct split apks, refer to my blog: TODO

A new script `splitapkAddSecurityExceptions.sh` is added to handle split apks for accepting user supplied CAs.

Another new script  `adbinstallsplitapk.sh` is added to help you easily install modified split apks on your device via `adb`.
