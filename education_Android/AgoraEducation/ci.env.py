#!/usr/bin/python
# -*- coding: UTF-8 -*-
import ast
import os
import re
import shutil

TARGET_LIBS_ZIP = "agora_sdk.zip"
TARGET_INTERNAL_FOLDER = "agora_sdk"


def main():
    rtcSdkUrl = ""
    if "rtcSdkUrl" in os.environ:
        rtcSdkUrl = os.environ["rtcSdkUrl"]
        downloadSDK(rtcSdkUrl)

    rtmSdkUrl = ""
    if "rtmSdkUrl" in os.environ:
        rtmSdkUrl = os.environ["rtmSdkUrl"]
        downloadSDK(rtmSdkUrl)

    if rtcSdkUrl.strip() or rtmSdkUrl.strip():
        if not os.path.exists("app/libs"):
            os.mkdir("app/libs")

        mv = "cp -f -r " + TARGET_INTERNAL_FOLDER + "/*/libs/* app/libs"
        os.system(mv)

        os.remove(TARGET_LIBS_ZIP)
        shutil.rmtree(TARGET_INTERNAL_FOLDER, ignore_errors=True)

    if "configFile" in os.environ and "configMap" in os.environ:
        configFile = os.environ["configFile"]
        print("configFile", configFile)
        configMap = ast.literal_eval(os.environ["configMap"])
        print("configMap", configMap)

        if configFile and configMap:
            # if need reset
            f = open(configFile, 'r+')
            content = f.read()

            contentNew = content
            for key in configMap:
                print("key", key)
                contentNew = re.sub(r'<#' + key + '#>', configMap[key], contentNew)

            f.seek(0)
            f.write(contentNew)
            f.truncate()


def downloadSDK(url):
    wget = "wget " + url + " -O " + TARGET_LIBS_ZIP
    os.system(wget)

    unzip = "unzip " + TARGET_LIBS_ZIP + " \"*/libs/*\" -d " + TARGET_INTERNAL_FOLDER
    os.system(unzip)


if __name__ == "__main__":
    main()
