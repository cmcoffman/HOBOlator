#data import
#set the filepath to where the files are
#setwd("~/Documents/Research/Schultzlab/HOBOlator")
filepath=file.path("2015_02_18")
filepath=normalizePath(filepath)
source("import_all_files.R")





         
#temp=HOBO

#XTSDATA <- xts(temp[, -6], temp[, 6])
#temp=XTSDATA["T08:30:00/T16:30:00"]
#mean(as.numeric(temp$temp), na.rm=TRUE)
