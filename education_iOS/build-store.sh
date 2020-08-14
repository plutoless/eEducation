#!/bin/sh
ArchivePath=AgoraEducation.xcarchive
IPAName="IPA"

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration Release
xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration Release -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportStorePlist.plist -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/AgoraEducation.ipa AgoraEducation.ipa

