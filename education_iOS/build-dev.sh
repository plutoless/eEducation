#!/bin/sh
ArchivePath=AgoraEducationDev.xcarchive
IPAName="IPADEV"

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration DevRelease
xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration DevRelease -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/AgoraEducation.ipa AgoraEducationDev.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F  "file=@AgoraEducationDev.ipa"
