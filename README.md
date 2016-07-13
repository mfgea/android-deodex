DEODEXING Script for Android apps
=================================

Prerequisites
-------------

OSX (Tested in El Capitan):

- p7zip (`brew install p7zip`)
- adb (`brew install android-platform-tools`)
- java ([http://www.oracle.com/technetwork/java/javase/downloads/index.html](Java downloads page))



Running
-------

You just have to run `./deodex.sh` and follow the menu items. Minimal steps are:

- [1] Create working directory
- [2] Pull files from your device
- [3] Deodex files
- [4] Add deodexed files to zip
- [6] Exit

You can optionally run option [5] to zipalign the apk files, like this:

- [1] Create working directory
- [2] Pull files from your device
- [3] Deodex files
- [5] Zipalign apk
- [4] Add deodexed files to zip
- [6] Exit


Options
-------

### [1] Create working directory

Just creates working directories, for the files to be copied into: system/app, system/priv-app and system/framework.


### [2] Pull files from your device

This copies the necesary files from the device. The device must be known and found by adb, so you should first run `adb devices` to make sure, and avoid issues. Files copied are located in: `system/app`, `system/priv-app` and `system/framework`.


### [3] Deodex files

Deodexes the apks, means, removing odex files. This files are optimized metainformation files for the dalvik engine. These load before the application runs (at system startup) so the applications load much faster. But dalvik has a cache, that precisely caches this information. So deodexed systems only have slow app starts on the first run, or after emptying dalvik's cache.


### [4] Add deodexed files to zip

Adds the generated files to the zip that will be later uploaded to the sd card.


### [5] Zipalign apk

This options zipaligns the apks. It optimizes the way the packages are packaged. Must be run before creating the zip file.


### [6] Exit

Well, you know this one...


