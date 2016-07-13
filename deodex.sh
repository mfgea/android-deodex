#!/bin/bash

function pause(){
    read -p "Press [Enter] key to continue..."
}

function working_dir(){
    clear
    echo Creating working directory and output folders...
    echo app
    mkdir system
    mkdir system/app
    mkdir system/priv-app
    mkdir system/framework
    echo Please dismiss error if you already have output folders.
    pause
    clear
}

function pull_files() {
    clear
    echo Connect your device to PC...
    pause
    adb kill-server
    adb start-server
    echo Pulling files from your device...
    adb pull /system/app system/app
    adb pull /system/priv-app system/priv-app
    adb pull /system/framework system/framework
    pause
    clear
}

function deodex() {
    clear
    echo;
    echo Starting deodex...
    mkdir work
    echo Starting deodex >log.txt 2>&1
    echo; >>log.txt 2>&1

    if [ -r system/framework/playstationcertified.odex ]; then
        mv system/framework/playstationcertified.odex com.playstation.playstationcertified.odex
    fi
    if [ -r system/framework/cneapiclient_release.odex ]; then
        mv system/framework/cneapiclient_release.odex cneapiclient.odex
    fi
    if [ -r system/framework/com.quicinc.cne_release.odex ]; then
        mv system/framework/com.quicinc.cne_release.odex com.quicinc.cne.odex
    fi

    for i in `ls -1 system/{app,priv-app,framework}/*.{apk,jar}`; do
        base=`basename $i`
        filename="${i%.*}"
        appname="${base%.*}"
        echo; >>log.txt 2>&1
        echo Target $filename >>log.txt 2>&1
        echo Deodexing $filename
        if [ -r $filename.odex ]; then
            echo Decompiling $filename.odex >>log.txt 2>&1
            java -jar cmd/baksmali.jar -d system/framework -x $filename.odex -o work/$appname >>log.txt 2>&1
            echo Compiling $appname >>log.txt 2>&1
            java -jar cmd/smali.jar work/$appname -o classes.dex >>log.txt 2>&1
            echo Zipping to $i >>log.txt 2>&1
            7za a -tzip $i classes.dex >>log.txt 2>&1
            rm classes.dex >>log.txt 2>&1
            rm $filename.odex >>log.txt 2>&1
        fi
    done

    for i in `find ./system -iname '*.odex'`; do
        echo $i was not deodexed.
        echo Not deodexed $i >>log.txt 2>&1
    done

    echo;
    echo Deodexed files are stored in system/app, system/priv-app, system/framework folder.
    echo Log is saved in log.txt.
    pause
    clear
}

function add_to_zip() {
    clear
    echo;
    echo Adding deodexed files to deodex_install.zip
    TEMPDATE=`date +%Y%m%d`
    TEMPTIME=`date +%H%M%S`
    cp cmd/deodex_install.zip "deodex_install_${TEMPDATE}-${TEMPTIME}.zip"
    7za a -tzip "deodex_install_${TEMPDATE}-${TEMPTIME}.zip" system
    echo Deleting work folder...
    rmdir -qr work >>log.txt 2>&1
    echo Completed.
    echo Log is saved in log.txt.
    pause
    clear
}

function zipalign() {
    clear
    for i in `ls -1 system/{app,priv-app,framework}/*.apk`; do
        filename="${i%.*}"
        base=`basename $i`
        appname="${base%.*}"

        cmd/zipalign -f 4 $i ${filename}_zipal.apk
        rm -q $i
        mv ${filename}_zipal.apk $i
    done

    echo;
    echo Zipalign completed.
    pause
    clear
}

while [ 1 ]; do
    echo "************ Menu ************************"
    echo [1] : Create working directory
    echo [2] : Pull files from your device
    echo [3] : Deodex files
    echo [4] : Add deodexed files to zip
    echo [5] : Zipalign apk
    echo [6] : Exit
    echo "******************************************"
    read -p "Select > " NUM

    if [ $NUM -eq 1 ]; then
        working_dir
    fi

    if [ $NUM -eq 2 ]; then
        pull_files
    fi
    if [ $NUM -eq 3 ]; then
        deodex
    fi
    if [ $NUM -eq 4 ]; then
        add_to_zip
    fi
    if [ $NUM -eq 5 ]; then
        zipalign
    fi
    if [ $NUM -eq 6 ]; then
        exit
    fi
done

