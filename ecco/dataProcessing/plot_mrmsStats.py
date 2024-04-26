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
import geopandas
import netCDF4 as nc
from matplotlib import dates
import datetime
import pathlib
from matplotlib.dates import DateFormatter
import pandas as pd
import pickle
import pyUtils.createFileList

def main():

    indir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/statMats/'
    infile='mrmsStats_20220502_to_20220502.pickle'
    
    figdir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/'
    
    stringDate=infile[-26:-7]
    
    with open(indir+infile, 'rb') as handle:
        echoType2D=pickle.load(handle)
    
    xlims=[min(echoType2D['lon']),max(echoType2D['lon'])]
    ylims=[min(echoType2D['lat']),max(echoType2D['lat'])]
    
    #bounds = geopandas.read_file('/scr/cirrus2/rsfdata/projects/nexrad-mrms/PoliticalBoundaries_Shapefile/NA_PoliticalDivisions/data/bound_p/boundaries_p_2021_v3.shp')
    bounds = geopandas.read_file('/scr/cirrus2/rsfdata/projects/nexrad-mrms/PoliticalBoundaries_Shapefile/stanford/ns372xw1938.shp')
    fig1=plt.figure(figsize=(10,13))
    
    for key,value in echoType2D.items():
        if key!='lon' and key!='lat' and key!='countAll':
            
            ax1 = fig1.add_subplot(8,2,1)
            bounds.boundary.plot()
            stopHere=1;
            
########################################################################
# Run - entry point

if __name__ == "__main__":
   main()

