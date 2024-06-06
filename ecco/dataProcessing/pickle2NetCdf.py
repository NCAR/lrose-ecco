#!/usr/bin/env python3

#===========================================================================
#
# Process MRMS ECCO output
#
#===========================================================================

import sys
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.pylab as pl
import netCDF4 as nc
import pandas as pd
import datetime
import pickle
import xarray as xr

def main():

    plt.close('all')
    
    indir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/statMats/'
    infile='mrmsStats_20220501_to_20220531.pickle'
    
    figdir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/'
    
    with open(indir+infile, 'rb') as handle:
        indata=pickle.load(handle)
        
    time=pd.date_range("2022-05-01", periods=24, freq="h")
    dX=xr.Dataset(
        data_vars=dict(
            StratLow=(["loc"], indata["StratLow"]),
            StratMid=(["loc"], indata["StratMid"]),
        ),
        coords=dict(
            time=("loc",time),
            lat=("loc", indata["lat"]),
            lon=("loc", indata["lon"]),
            ),
        attrs=dict(description="ConvStrat"),
        )
    stopHere=1
    
               
########################################################################
# Run - entry point

if __name__ == "__main__":
   main()

