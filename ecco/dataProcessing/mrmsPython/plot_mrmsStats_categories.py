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
import cartopy
import cartopy.feature as cfeature
import cartopy.crs as ccrs
from cartopy.util import add_cyclic_point
#import netCDF4 as nc
#from matplotlib import dates
#import datetime
#import pathlib
#from matplotlib.dates import DateFormatter
#import pandas as pd
import pickle
from mpl_toolkits.basemap import Basemap

def main():

    plt.close('all')
    
    indir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/ecco_stats/'
    infile='mrmsStats_20220501_to_20220501.pickle'
    
    figdir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/'
    
    with open(indir+infile, 'rb') as handle:
        echoType2D=pickle.load(handle)
    
    xlims=[min(echoType2D['lon']),max(echoType2D['lon'])]
    ylims=[min(echoType2D['lat']),max(echoType2D['lat'])]
    
    resol = '50m'
    provinc_bodr = cartopy.feature.NaturalEarthFeature(category='cultural', 
        name='admin_1_states_provinces_lines', scale=resol, facecolor='none', edgecolor='k')
   
    fig, ax= plt.subplots(4,2,subplot_kw={'projection': ccrs.PlateCarree()},figsize=(12,12),constrained_layout=True)
    ax=ax.ravel()
    ii=0
    for jj, (key,value) in enumerate(echoType2D.items()):
        if key not in ['CountAllHours','CountAllEcho','lon','lat']:
            valSum=np.sum(value,0)
            valSum[valSum==0]='nan'
            echoSum=np.sum(echoType2D['CountAllEcho'],0)
            echoSum[echoSum==0]='nan'
            valNorm=valSum/echoSum
            clevs=np.arange(0,np.nanpercentile(valNorm,100),0.01)
            
            cs=ax[ii].contourf(echoType2D['lon'], echoType2D['lat'], valNorm,
                clevs,cmap='turbo',extend='both')
            ax[ii].coastlines()
            ax[ii].add_feature(cfeature.BORDERS)
            ax[ii].add_feature(provinc_bodr, linestyle='--', linewidth=0.6, edgecolor="k", zorder=10)
            ax[ii].set_xticks(np.arange(xlims[0],xlims[1]+1,10))
            ax[ii].set_yticks(np.arange(ylims[0],ylims[1]+1,10))
            ax[ii].set_title(key,fontweight='bold')
            ii=ii+1
                
    fig.colorbar(cs, ax=ax.ravel().tolist(), shrink=0.4, fraction=0.5)
    plt.show()
    
    plt.savefig(figdir+'categories_'+infile[-27:-7]+'.png')
    
    plt.close(fig)
               
########################################################################
# Run - entry point

if __name__ == "__main__":
   main()

