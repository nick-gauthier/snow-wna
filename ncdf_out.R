library(stars)
library(dplyr)
library(ncdf4)

ensemble <- readRDS('~/Downloads/snow-ensemble/ensemble.rds')

ens_dims <- st_dimensions(ensemble)
st_get_dimension_values(ens_dims, 'run')
rm(ensemble)
gc()
ensemble_dat <- readRDS('~/Downloads/snow-ensemble/ensemble.rds') %>% pull(swe)
gc()
# create and write the netCDF file -- ncdf4 version
# define dimensions
londim <- ncdim_def("lon","degrees_east", st_get_dimension_values(ens_dims, 'x'))
latdim <- ncdim_def("lat","degrees_north", st_get_dimension_values(ens_dims, 'y'))
timedim <- ncdim_def("time",'year_CE', st_get_dimension_values(ens_dims, 'time'))
rundim <- ncdim_def("run",'', st_get_dimension_values(ens_dims, 'run'))

# define variables
dlname <- "March mean snow water equivalent"
swe_def <- ncvar_def("swe","mm",list(londim,latdim,timedim,rundim), longname = dlname)

# create netCDF file and put arrays
ncout <- nc_create('swe_ensemble_ccsm.nc',list(swe_def),force_v4=TRUE)

# put variables
ncvar_put(ncout,swe_def, ensemble_dat)
rm(ensemble_dat)
gc()

# put additional attributes into dimension and data variables
ncatt_put(ncout,"lon","axis","X") #,verbose=FALSE) #,definemode=FALSE)
ncatt_put(ncout,"lat","axis","Y")
ncatt_put(ncout,"time","axis","T")

# add global attributes
ncatt_put(ncout,0,"title",'Prototype downscaled SWE over the western US over the Last Millennium')
ncatt_put(ncout,0,"institution",'University of Arizona')
ncatt_put(ncout,0,"source",'CCSM4')
history <- paste("Nick Gauthier", date(), sep=", ")
ncatt_put(ncout,0,"history",history)
ncatt_put(ncout,0,"Conventions",'CF-1.6')

# Get a summary of the created file:
ncout
