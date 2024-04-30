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

    indir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/statMats/'
    infile='mrmsStats_20220501_to_20220601.pickle'
    
    figdir='/scr/cirrus2/rsfdata/projects/nexrad-mrms/figures/eccoStats/'
    
    stringDate=infile[-26:-7]
    
    with open(indir+infile, 'rb') as handle:
        echoType2D=pickle.load(handle)
    
    xlims=[min(echoType2D['lon']),max(echoType2D['lon'])]
    ylims=[min(echoType2D['lat']),max(echoType2D['lat'])]
    
    resol = '50m'
    provinc_bodr = cartopy.feature.NaturalEarthFeature(category='cultural', 
        name='admin_1_states_provinces_lines', scale=resol, facecolor='none', edgecolor='k')
   
    for jj, (key,value) in enumerate(echoType2D.items()):
        if key not in ['countAll','lon','lat']:
            fig, ax= plt.subplots(4,3,subplot_kw={'projection': ccrs.PlateCarree()},figsize=(17,12))
            ax=ax.ravel()
            clevs=np.arange(0,np.nanpercentile(value,99),10)
            for ii in range(12):
                cs=ax[ii].contourf(echoType2D['lon'], echoType2D['lat'], value[ii,:,:],
                    clevs,cmap='coolwarm',extend='both')
                ax[ii].coastlines()
                ax[ii].add_feature(cfeature.BORDERS)
                ax[ii].add_feature(provinc_bodr, linestyle='--', linewidth=0.6, edgecolor="k", zorder=10)
                ax[ii].set_xticks(np.arange(xlims[0],xlims[1]+1,10))
                ax[ii].set_yticks(np.arange(ylims[0],ylims[1]+1,10))
                ax[ii].set_title(key+' '+str(ii)+' to '+str(ii+1)+' ST',fontweight='bold')
                
            # Add a colorbar axis at the bottom of the graph
            cbar_ax = fig.add_axes([0.2, 0.2, 0.6, 0.02])

            # Draw the colorbar
            cbar=fig.colorbar(cs, cax=cbar_ax,orientation='horizontal')
                
            fig.tight_layout()
                
            stpP=1
            
########################################################################
# Run - entry point

if __name__ == "__main__":
   main()

