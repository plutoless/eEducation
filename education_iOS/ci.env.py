#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys

def main():
    os.system("pod install")
    agoraAuth = ""
    if "auth" in os.environ:
        agoraAuth = os.environ["auth"]
        
    agoraAppId = ""
    agoraHost = ""
    
    env = sys.argv[1]
    if (env != "1" and env != "2" and env != "3"):
        env = 1

    if env == 1:
        if "appId_demo" in os.environ:
            agoraAppId = os.environ["appId_demo"]
        if "host_debug" in os.environ:
            agoraHost = os.environ["host_debug"]
            agoraHost = agoraHost[:-1]
    if env == 2:
        if "appId_pre" in os.environ:
            agoraAppId = os.environ["appId_pre"]
        if "host_pre" in os.environ:
            agoraHost = os.environ["host_pre"]
            agoraHost = agoraHost[:-1]
    if env == 3:
        if "appId_release" in os.environ:
            agoraAppId = os.environ["appId_release"]
        if "host_release" in os.environ:
            agoraHost = os.environ["host_release"]
            agoraHost = agoraHost[:-1]
        
    f = open("./AgoraEducation/KeyCenter.m", 'r+')
    content = f.read()
    agoraAppIdString = "@\"" + agoraAppId + "\""
    agoraAuthString = "@\"" + agoraAuth + "\""
    
    contentNew = re.sub(r'<#Your Agora App Id#>', agoraAppIdString, content)
    contentNew = re.sub(r'<#Your Authorization#>', agoraAuthString, contentNew)

    f.seek(0)
    f.write(contentNew)
    f.truncate()
    
    f = open("./AgoraEducation/Manager/HTTP/URL.h", 'r+')
    content = f.read()
    agoraHostString = agoraHost
    
    contentNew = re.sub(r'https://api.agora.io', agoraHostString, content)

    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
