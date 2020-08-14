#!/usr/bin/env python
# encoding: utf-8

import imp
import sys
import os
import glob
import string 
import re 
import time
 
imp.reload(sys)
sys.setdefaultencoding('utf-8') #设置默认编码,只能是utf-8,下面\u4e00-\u9fa5要求的
 
KSourceFile = 'Base.lproj/*.storyboard'
 
KTargetFile = '*.lproj/*.strings' 
 
KGenerateStringsFile = 'TempfileOfStoryboardNew.strings'
 
ColonRegex = ur'["](.*?)["]'
 
KeyParamRegex = ur'["](.*?)["](\s*)=(\s*)["](.*?)["];'
 
AnotationRegexPrefix = ur'/(.*?)/'
 
def getCharaset(string_txt):
    filedata = bytearray(string_txt[:4])
    if len(filedata) < 4 :
        return 0
    if  (filedata[0] == 0xEF) and (filedata[1] == 0xBB) and (filedata[2] == 0xBF):
        print 'utf-8'
        return 1
    elif (filedata[0] == 0xFF) and (filedata[1] == 0xFE) and (filedata[2] == 0x00) and (filedata[3] == 0x00):
        print 'utf-32/UCS-4,little endian'
        return 3
    elif (filedata[0] == 0x00) and (filedata[1] == 0x00) and (filedata[2] == 0xFE) and (filedata[3] == 0xFF):
        print 'utf-32/UCS-4,big endian'
        return 3
    elif (filedata[0] == 0xFE) and (filedata[1] == 0xFF):
        print 'utf-16/UCS-2,little endian'
        return 2
    elif (filedata[0] == 0xFF) and (filedata[1] == 0xFE):
        print 'utf-16/UCS-2,big endian'
        return 2
    else:
        print 'can not recognize!'
        return 0
 
def decoder(string_txt):
    var  = getCharaset(string_txt)
    if var == 1:
        return string_txt.decode("utf-8")
    elif var == 2:
        return string_txt.decode("utf-16")
    elif var == 3:
        return string_txt.decode("utf-32")
    else:
        return string_txt
 
def constructAnotationRegex(str):
    return AnotationRegexPrefix + '\n' + str
 
def getAnotationOfString(string_txt,suffix):
    anotationRegex = constructAnotationRegex(suffix)
    anotationMatch = re.search(anotationRegex,string_txt)
    anotationString = ''
    if anotationMatch:
        match = re.search(AnotationRegexPrefix,anotationMatch.group(0))
        if match:
            anotationString = match.group(0)
    return anotationString
 
def compareWithFilePath(newStringPath,originalStringPath):
    #read newStringfile
    nspf=open(newStringPath,"r")
    #newString_txt =  str(nspf.read(5000000)).decode("utf-16")
    newString_txt =  decoder(str(nspf.read(5000000)))
    nspf.close()
    newString_dic = {}
    anotation_dic = {}
    for stfmatch in re.finditer(KeyParamRegex , newString_txt):
        linestr = stfmatch.group(0)
        anotationString = getAnotationOfString(newString_txt,linestr)
        linematchs = re.findall(ColonRegex, linestr)
        if len(linematchs) == 2:
            leftvalue = linematchs[0]
            rightvalue = linematchs[1]
            newString_dic[leftvalue] = rightvalue
            anotation_dic[leftvalue] = anotationString
    #read originalStringfile
    ospf=open(originalStringPath,"r")
    originalString_txt =  decoder(str(ospf.read(5000000)))
    ospf.close()
    originalString_dic = {}
    for stfmatch in re.finditer(KeyParamRegex , originalString_txt):
        linestr = stfmatch.group(0)
        linematchs = re.findall(ColonRegex, linestr)
        if len(linematchs) == 2:
            leftvalue = linematchs[0]
            rightvalue = linematchs[1]
            originalString_dic[leftvalue] = rightvalue
    #compare and remove the useless param in original string
    for key in originalString_dic:
        if(key not in newString_dic):
            keystr = '"%s"'%key
            replacestr = '//'+keystr
            match = re.search(replacestr , originalString_txt)
            if match is None:
                originalString_txt = originalString_txt.replace(keystr,replacestr)
    #compare and add new param to original string
    executeOnce = 1
    for key in newString_dic:
        values = (key, newString_dic[key])
        if(key not in originalString_dic):
            newline = ''
            if executeOnce == 1:
                timestamp = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
                newline = '\n//##################################################################################\n'
                newline +='//#           AutoGenStrings            '+timestamp+'\n'
                newline +='//##################################################################################\n'
                executeOnce = 0
            newline += '\n'+anotation_dic[key]
            newline += '\n"%s" = "%s";\n'%values
            originalString_txt += newline
    #write into origial file
    sbfw=open(originalStringPath,"w")
    sbfw.write(originalString_txt)
    sbfw.close()
 
def extractFileName(file_path):
    seg = file_path.split('/')
    lastindex = len(seg) - 1
    return seg[lastindex]
 
def extractFilePrefix(file_path):
    seg = file_path.split('/')
    lastindex = len(seg) - 1
    prefix =  seg[lastindex].split('.')[0]
    return prefix
 
def generateStoryboardStringsfile(storyboard_path,tempstrings_path):
    cmdstring = 'ibtool '+storyboard_path+' --generate-strings-file '+tempstrings_path
    if os.system(cmdstring) == 0:
        return 1
 
def main():
    filePath = sys.argv[1]
    sourceFilePath = filePath + '/' + KSourceFile
    sourceFile_list = glob.glob(sourceFilePath)
    if len(sourceFile_list) == 0:
        print 'error dictionary,you should choose the dic upper the Base.lproj'
        return
    targetFilePath = filePath + '/' + KTargetFile
    targetFile_list = glob.glob(targetFilePath)
    tempFile_Path = filePath + '/' + KGenerateStringsFile
    if len(targetFile_list) == 0:
        print 'error framework , no .lproj dic was found'
        return
    for sourcePath in sourceFile_list:
        sourceprefix = extractFilePrefix(sourcePath)
        sourcename = extractFileName(sourcePath)
        print 'init with %s'%sourcename
        if generateStoryboardStringsfile(sourcePath,tempFile_Path) == 1:
            print '- - genstrings %s successfully'%sourcename
            for targetPath in targetFile_list:
                targetprefix = extractFilePrefix(targetPath)
                targetname = extractFileName(targetPath)
                if cmp(sourceprefix,targetprefix) == 0:
                    print '- - dealing with %s'%targetPath
                    compareWithFilePath(tempFile_Path,targetPath)
            print 'finish with %s'%sourcename
            os.remove(tempFile_Path)
        else:
            print '- - genstrings %s error'%sourcename
 
 
 
 
if __name__ == '__main__':
    main()