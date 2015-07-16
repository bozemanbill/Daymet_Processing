###################################################################################
# William Kleindl, PhD 
# University of Montana
###################################################################################

###################################################################################
# Daymet processing provided in the read-me and the attached code will walk through:
# 1.	Acquiring Daymet data - see readme
# 2.	Data and file preparation - see readme
# 3.	Code Preliminaries - see readme and below
# 4.	Organizing output directories, Raster merging, clipping and masking for multiple years

###################################################################################
# 3.	Code Preliminaries
#load packages
library(rgdal)
library(maptools)
library(sp)
library(raster)
library(ncdf)
library(plyr)

#Set working directory and import study area.
wd<-setwd("D:/Publications/nf hydro/Climate Data")
sa_lambert<-readOGR(dsn="D:/Research/Past Research/Climate Data/Lambert Study Area",layer="nrth_fork_lambert")

# Establish the list of files in the working directory.  This will set things up for the batch processing later.
#list the directories in the folder then appends the pathname to each folders in the subdirectories 
dir_ras<-list.dirs(path = ".", full.names=F, recursive =F) 
dir_east<-list.dirs(dir_ras[1], recursive=F)
dir_west <-list.dirs(dir_ras[3], recursive=F)

#Showing the following directories. 
dir_ras
dir_east

#############################
# 4.	Organizing output directories, Raster merging, clipping and masking for multiple years:
#In the batch steps below a Netcdf file from a specific year and specific attribute will be 
#converted to raster, clipped, masked, and merged with a matching file from the next tile. This
#new file will be renamed with the year attached and saved in an output directory specific to 
#the attribute. These folders have already been established in the preliminaries above. 
#The following code established that directory name. The example here is for years 2010 to 2014.

i=1
k=2010
while(k < 2015) {
  j=1
  files_east <-list.files(dir_east[i], recursive=F)
  files_west <-list.files(dir_west[i], recursive=F)
  while(j < 8) {
    thefile <-(files_east[j])
    met<-substr(thefile,1,2)
    temp<-substr(thefile,1,3)
    #Determine variable name
    out.dir <-ifelse(met=="da","day_length",
                     ifelse(met=="pr", "precipitation",
                            ifelse(met=="sr", "solar_radiation",
                                   ifelse (met=="sw", "Snow_water",
                                           ifelse (met=="vp", "vapor_pressure",
                                                   ifelse(temp=="tma","tmax", "tmin"))))))
    floc <- paste0("D:/Publications/nf hydro/Climate Data/Final Met/",out.dir)
    #merges east and west files by attribute and year
    files_east_ras<-brick(paste0(dir_east[i],"/",files_east[j]))
    files_west_ras<-brick(paste0(dir_west[i],"/",files_west[j]))
    merge<-merge(files_east_ras,files_west_ras)
    #crop and mask to study area
    sa_crop<-crop(merge, sa_lambert)
    sa_mask<-mask(sa_crop,sa_lambert)
    new_name <-sub(pattern=".nc", replacement= paste0(k,".tif"),files_east[j])
    # write to a new geotiff file (depends on rgdal) R can' t #write multi-layer ascii!! 
    name <-paste0(floc,"/",new_name)
    xxx <-writeRaster(sa_mask, filename=name, format="GTiff", overwrite=TRUE)
    j=j+1
  }
  i=i+1
  k=k+1
}

#############################
# I use these files to create met input for an HBV-EC hydro model. Look at my code called "HBV-EC Met Prep"
# to see how I derive daily means with zonal statistics and create final file preparation for model 
# input (including issues with leap years).


