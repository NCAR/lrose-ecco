#!/usr/bin/env python3

#===========================================================================
#
# Process MRMS ECCO output
#
#===========================================================================

import sys
from optparse import OptionParser
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.pylab as pl
import netCDF4 as nc
from matplotlib import dates
import datetime
import pathlib
from matplotlib.dates import DateFormatter
import pandas as pd
import pickle
import pyUtils.createFileList

def main():

    # globals

    global options
    global debug
    global startTime
    global endTime
    global timeLimitsSet
    timeLimitsSet = False
    global figNum
    figNum = 0
    
    # parse the command line

    usage = "usage: %prog [options]"
    parser = OptionParser(usage)
    parser.add_option('--start',
                      dest='startTime',
                      default='2022 05 01 00 00 00',
                      help='Start time for processing')
    parser.add_option('--end',
                      dest='endTime',
                      default='2022 06 01 00 00 00',
                      help='End time for processing')
    parser.add_option('--inDir',
                      dest='inDir',
                      default='/scr/cirrus2/rsfdata/projects/nexrad-mrms/ecco_conus_terrain/',
                      help='Directory for output data')
    parser.add_option('--outDir',
                      dest='outDir',
                      default='/scr/cirrus2/rsfdata/projects/nexrad-mrms/statMats/',
                      help='Directory for output data')
        
    
    (options, args) = parser.parse_args()
    
    # time limits
    year, month, day, hour, minute, sec = options.startTime.split()
    startTime = datetime.datetime(int(year), int(month), int(day),
                                  int(hour), int(minute), int(sec))

    year, month, day, hour, minute, sec = options.endTime.split()
    endTime = datetime.datetime(int(year), int(month), int(day),
                                int(hour), int(minute), int(sec))

    # Create file list
    fileList=pyUtils.createFileList.createFileList(options.inDir, startTime, endTime, '%Y%m%d_%H%M%S.mdv.cf.nc', 1)
    
    # Read data
    
    timeBase=datetime.datetime(1970,1,1)
    
    readThis=nc.Dataset(fileList[0],'r')
    lon=readThis.variables['x0'][:]
    lat=readThis.variables['y0'][:]
    
    initArray=np.zeros((24,len(lat),len(lon)))
    StratLow=initArray
    StratMid=initArray
    StratHigh=initArray
    Mixed=initArray
    ConvElev=initArray
    ConvShallow=initArray
    ConvMid=initArray
    ConvDeep=initArray
    
    countAll=np.full((len(lat),len(lon)),0)
            
    for readFile in fileList:
        print(readFile)
        readThis=nc.Dataset(readFile,'r')
        
        readThis=nc.Dataset(readFile,'r')
        timeIn=readThis.variables['time'][:]
        time=timeBase+datetime.timedelta(seconds=timeIn[0])
        
        # Mean solar time
        mst=np.empty(len(lon), dtype='datetime64[s]')
        mstHours=np.empty([1,len(lon)]).astype('float64')
        for ii in range(0,len(lon)):
            mst[ii]=time+datetime.timedelta(minutes=lon[ii]*4)
            mstHours[0,ii]=mst[ii].astype(object).hour
            
        mstHours2D=np.repeat(mstHours,len(lat),0)
        
        echoType2Din=np.squeeze(readThis.variables['EchoTypeComp'][:])
        echoType2Din=echoType2Din.filled(fill_value=np.nan)
        
        for ii in range(0,23):
            #print(ii)
            StratLow[ii,:,:]=StratLow[ii,:,:]+((echoType2Din==14) & (mstHours2D==ii)).astype(int)
            StratMid[ii,:,:]=StratMid[ii,:,:]+((echoType2Din==16) & (mstHours2D==ii)).astype(int)
            StratHigh[ii,:,:]=StratHigh[ii,:,:]+((echoType2Din==18) & (mstHours2D==ii)).astype(int)
            Mixed[ii,:,:]=Mixed[ii,:,:]+((echoType2Din==25) & (mstHours2D==ii)).astype(int)
            ConvElev[ii,:,:]=ConvElev[ii,:,:]+((echoType2Din==32) & (mstHours2D==ii)).astype(int)
            ConvShallow[ii,:,:]=ConvShallow[ii,:,:]+((echoType2Din==34) & (mstHours2D==ii)).astype(int)
            ConvMid[ii,:,:]=ConvMid[ii,:,:]+((echoType2Din==36) & (mstHours2D==ii)).astype(int)
            ConvDeep[ii,:,:]=ConvDeep[ii,:,:]+((echoType2Din==38) & (mstHours2D==ii)).astype(int)
            
            countAll[(mstHours2D==ii)]=countAll[(mstHours2D==ii)]+1;
    
    echoType2D={
        "countAll":countAll,
        "lon":lon,
        "lat":lat,
        "StratLow":StratLow,
        "StratMid":StratMid,
        "StratHigh":StratHigh,
        "Mixed":Mixed,
        "ConvElev":ConvElev,
        "ConvShallow":ConvShallow,
        "ConvMid":ConvMid,
        "ConvDeep":ConvDeep
    }
    
    outfile=options.outDir+'mrmsStats_'+startTime.strftime("%Y%m%d")+'_to_'+endTime.strftime("%Y%m%d")+'.pickle'
    with open(outfile, 'wb') as handle:
        pickle.dump(echoType2D, handle, protocol=pickle.HIGHEST_PROTOCOL)
    
########################################################################
# Run - entry point

if __name__ == "__main__":
   main()

