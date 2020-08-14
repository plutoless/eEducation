#!/bin/sh
ArchivePathQA=AgoraEducationQA.xcarchive
IPANameQA="IPAQA"

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QARelease
xcodebuild -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QARelease -archivePath ${ArchivePathQA} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePathQA} -exportPath ${IPANameQA} -quiet || exit
cp ${IPANameQA}/AgoraEducation.ipa AgoraEducationQA.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F  "file=@AgoraEducationQA.ipa"
