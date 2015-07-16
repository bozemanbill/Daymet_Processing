###################################################################################
# William Kleindl, PhD 
# University of Montana
# 401 S. 8th Ave 
# Bozeman, MT  59715 
# 406-599-7721  
###################################################################################

###################################################################################
# Daymet processing provided in the read-me and the attached code will walk through:
# 1.	Acquiring Daymet data 
# 2.	Data and file preparation 
# 3.	Code Preliminaries 
# 4.	Organizing output directories, Raster merging, clipping and masking for multiple years

###################################################################################
# Disclaimer:  First thing you need to realize is that I don’t really know what I am doing. I needed to derive daily means of Daymet data for a hydrological model of a ~5000 sq km watershed just west of Glacier National Park, USA. I could not find a method or tool that could help, so I made the following tool in R.  But, currently I am about as good with R as I am with carpentry.  I keep adding wood until it stops wiggling and eventually it looks like a little like a chair and you can sit on it.  It is the same with the code below. It works, but I am sure there more elegant ways to get to the same end. If see problems, or know better ways to get there, please tell me. 

##################################################################################
# 1. Acquiring Data: Daymet documentation explains that the daily gridded meteorological data is distributed in 2 degree x 2 degree (~222 x 222km) “tiles” from the Daymet Thematic Real-time Environmental Data Services (THREDDS) server in CF-Compliant NetCDF format. The Daymet data is available from 1980 to 2014 (currently) and includes the multiple meteorological attributes. The attribute is in the form of a raster brick with 1km resolution and 365 layers deep (1 layer per day). Each brick is made up of specific met data (e.g. tmax, prcp), see the daymet webpage for details and download directions: http://daymet.ornl.gov/

##################################################################################
# 2. Data and file preparation: 
# A.	Download and un-compress the file. You will find folders for each year for that tile,
# B.	In those folders you will find a file called 'tile_year.tar.gz', unzip that and find yet another .tar file (don’t know why) called 'tile_year.tar', unzip that and find a folder with the met data,
# C.	Within each folder, the files will have the same name as any other year called 'metname.nc'.  Each file must be renamed to add the appropriate year, this is done in the R-code below, but to do that the files must first be prepared.
# D.	Create a working directory called ~/Data and within that two folders titled ‘East’ and ‘West’.
# E.	Rename that tile#_year folder by removing the tile number leaving a ‘year’ folder and place ‘year’ folder into the appropriate ‘East’ or ‘West’ folder.
# F.	Outside the working directory create a new (and currently empty) folder for final data called ‘Final Met’ with additional folders within for each final attribute; ‘Day_Length’, ‘Precipitation’, ‘Solar_Radiation’, ‘Snow_Water’, ‘Vapor_Pressure’, ‘Tmax’, and ‘Tmin’.  These will be filled later by the code output.

##################################################################################
#3. Code Prelininaries: The initial step is to define study area in ArcGIS. I added a 2 kilometer buffer to my own study area to make sure I would not lose any of the 1-sq.km climate data cells that partially extend beyond my watershed in later cropping, masking, and zonal statistics.  Because the Daymet has a variant of lambert projection that is unique to that data set, I converted the study area to that projection in ArcGIS (see projection parameters below).  It was easier for me to create one Lambert study area than to convert all the NCDF files to UTM 11 for my project’s projection.  Doesn’t make a difference in the final analysis, but for all subsequent cropping it must be in the DAYMET Lambert projection.  

#Projection System:  Lambert Conformal Conic
#Parameters: 
#projection units: meters 
#datum (spheroid): WGS_84 
#1st standard parallel: 25 deg N 
#2nd standard parallel: 60 deg N 
#Central meridian: -100 deg (W) 
#Latitude of origin: 42.5 deg N 
#false easting: 0 
#false northing: 0

##################################################################################
