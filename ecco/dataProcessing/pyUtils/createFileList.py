#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May  1 10:52:23 2018

@author: romatsch
"""

#===========================================================================
#
# Creates a list of files to read based on a start and end date
# Can search through one directory or through sub directories
#
#===========================================================================

import os
#import numpy as np
from datetime import datetime

def createFileList(dataPath, startTime, endTime, fileFormat,subdir):
    # If we also need to search through subdirectories
    if subdir:
        startYMD=datetime(startTime.year, startTime.month, startTime.day, 0, 0, 0)
        endYMD=datetime(endTime.year, endTime.month, endTime.day, 0, 0, 0)
        subdirList=sorted(os.listdir(dataPath)) #list with sub directories
        rightSubdirs=[]        
        for dirname in subdirList:
            if dirname[0]=='2':
                dirTime=datetime.strptime(dirname,'%Y%m%d')
                if startYMD<=dirTime<=endYMD:
                    rightSubdirs.append(dirname)    
        fileListIn=[]
        for subdirSearch in rightSubdirs:
            fileListIn=fileListIn+(sorted(os.listdir(dataPath+subdirSearch)))
    else:
        fileListIn=sorted(os.listdir(dataPath))
    #Now we have a list of all files in all correct subdirectories
    #We will sort out the ones in the right time frame
    fileListOut=[];
    for fileCheck in fileListIn:
        if fileCheck.endswith('.nc'):
            fileTimeStart=datetime.strptime(fileCheck,fileFormat)
            if startTime<=fileTimeStart<endTime:
                    fileListOut.append(fileCheck)
    # add directory path
    fileList=[]
    for fileAdd in fileListOut:
        if subdir:
            fileTime=datetime.strptime(fileAdd,fileFormat)
            fileList.append(dataPath+fileTime.strftime("%Y%m%d")+'/'+fileAdd)
        else:
            fileList.append(dataPath+fileAdd)
    return fileList
