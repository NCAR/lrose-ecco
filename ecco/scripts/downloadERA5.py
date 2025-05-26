import rdams_client as rc
import time

# Function to keep checking if a request is ready. (Used below.)
def check_ready(rqst_id, wait_interval=300): # Check every 300s=5min
    for i in range(288): # 288 is arbitrary. Total wait time for request is 24 hours (300s*288)
        res = rc.get_status(rqst_id)
        request_status = res['data']['status']
        if request_status == 'Completed':
            return True
        print(request_status)
        print('Not yet available. Waiting ' + str(wait_interval) + ' seconds.' )
        time.sleep(wait_interval)
    return False

# Control dict for subsetting. Describes which data is being downloaded.
control = { 
    'dataset' : 'ds633.0', # Dataset ID from the RDA website
    'date':'202412010000/to/202412312359', # Start and end date
    'datetype':'init',
    # Variables. Geopotential height (Z), U wind (U), V wind (V), vertical wind (W)
    # divergence (D), spec hum (Q), rel hum (R), temperature (T).
    'param':'Z/U/V/W/D/Q/R/T',
    # The levels below are named in a strange way. These are pressure levels.
    #The first number is the RDA level ID and the second number is the pressure level in hPa.
    #I.e., we are downloading all levels from 100 hPa to 1000 hPa.
    #'level':'2652:100;2653:125;2654:150;2655:175;2656:200;2657:225;2658:250;2659:300;2660:350;2661:400;2662:450;2663:500;2664:550;2665:600;2666:650;2667:700;2668:750;2669:775;2670:800;2671:825;2672:850;2673:875;2674:900;2675:925;2676:950;2677:975;2678:1000',
    'oformat':'netCDF', # Output format
    'nlat':55, # North latitude
    'slat':20, # South latitude
    'elon':-60, # East longitude
    'wlon':-130, # West longitude
    'product':'Analysis',
    'groupindex':26 # 26 is the index for the pressure level reanalysis.
}

# Submit a request and check if it went through without an error.
response = rc.submit_json(control)
print(response)

assert response['http_response'] == 200
rqst_id = response['data']['request_id']

print(response)

# Checks if a requst is ready. When it is, it will start to download the files. (Uses function from the top.)
check_ready(rqst_id)
rc.download(rqst_id)

# Purge request
rc.purge_request(rqst_id)
