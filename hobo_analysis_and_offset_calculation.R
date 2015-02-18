#this is just the data import and analysis in one script to make this simple to download
#and run on other computers, ive removed all the working directory switching,
#JUST RUN THE SCRIPT IN THE DIRECTORY YOU WANT and it will work on the *.csv files you see

#clear workspace
rm(list=ls())

#get packages
require("plyr")
require("xts")
#get list of files
files = c(list.files(pattern="*.txt"), list.files(pattern="*.csv"))

#change any spaces to underscores and add "data" to beginning to remove leading numbers, which R doesnt like
obj.names=paste(gsub(pattern=" ", replacement="_", files), sep="_")

#this function converts to POSIX compatible time format
make.time=function(df) {
  df$real.time=as.POSIXlt(strptime(df$date.time, format="%m/%d/%Y %I:%M:%S %p"), tz="CST")
  return(df)
}


#make a dummy variable for the number of columns in each file
num.col=NULL
junk.cols=NULL
col.classes=NULL
col.names=NULL

#column classes of the first 4 columns
class=c("numeric", "character", "numeric", "numeric")
name=c("measurement.index","date.time","temp","RH")

#actually read in the files
for (i in 1:length(files)) {
  
  #first figure out how many columns are in the file
  #because its oddly tricky to only read in the first x columns...
  num.col=max(count.fields(files[i], sep = ","))
  #column classes of the remaining columns (all "NULL")
  junk.cols=replicate(num.col-4, "NULL")
  #make a vector of column classes
  col.classes=c(class, junk.cols)
  col.names=c(name, junk.cols)
  assign(obj.names[i], read.csv(files[i], 
                                skip=2,
                                header=FALSE,
                                colClasses=col.classes,
                                col.names =col.names, 
                                
                                #colClasses=c("numeric", "character","numeric","numeric","NULL", "NULL","NULL","NULL","NULL","NULL","NULL","NULL","NULL"),
                                #col.names = c("measurement.index","date.time","temp","RH","dew.pt", "NULL","NULL","NULL","NULL","NULL","NULL","NULL"), 
  )) 
}

#make a list of all the dataframes
l.df <- lapply(ls(), function(x) if (class(get(x)) == "data.frame") get(x))

#make a dataframe that translates the filesnames to their object names
obj.to.filename=data.frame(Orginal.File=files, Object.Name=obj.names)

#make a new column called "make.time" which has posix compliant dates/times
for (i in 1:length(obj.names)) {
  assign(as.character(obj.names[i]), make.time(get(as.character(obj.names[i])))) 
}



#make a dataframe that translates the filesnames to their object names
obj.to.filename=data.frame(Orginal.File=files, Object.Name=obj.names)

#this script does the analysis on the files to look for temperature anomalies
#and suggest calibrations

#import data
#source("data_import.R")

#temp=HOBO_10A_Room_12.csv

#XTSDATA <- xts(temp[, -6], temp[, 6])
#temp=XTSDATA["T08:30:00/T16:30:00"]
#mean(as.numeric(temp$temp), na.rm=TRUE)

#add a chamber column specifying which dataframe it is 
#so when I merget them later I can tell them apart
for (i in 1:length(obj.to.filename$Object.Name)) {
  temp=get(as.character(obj.to.filename$Object.Name[i]))
  temp$chamber=obj.to.filename$Orginal.File[i]
  assign(as.character(obj.to.filename$Object.Name[i]), temp)
}
rm(temp)
rm(i)

#rbind all the dataframes
# create a list of data frames
x.list <- lapply(obj.names, get)

# combine into a single dataframe
all.data=do.call(rbind, x.list)

#summarize data
all.data.summary <- ddply(all.data, c("chamber"), summarise,
                          mean.temp = mean(temp, na.rm=TRUE),
                          sd.temp = sd(temp, na.rm=TRUE),
                          mean.RH = mean(RH, na.rm=TRUE),
                          sd.RH   = sd(RH, na.rm=TRUE))

#subset by night and day
XTSDATA <- xts(all.data[, -5], all.data[, 5])
all.data.days=as.data.frame(XTSDATA["T08:30:00/T16:30:00"])
all.data.days$temp=as.numeric(as.character(all.data.days$temp))
all.data.days$RH=as.numeric(as.character(all.data.days$RH))
#all.data.days$dew.pt=as.numeric(as.character(all.data.days$dew.pt))

all.data.nights=as.data.frame(XTSDATA["T16:30:00/T08:30:00"])
all.data.nights$temp=as.numeric(as.character(all.data.nights$temp))
all.data.nights$RH=as.numeric(as.character(all.data.nights$RH))
#all.data.nights$dew.pt=as.numeric(as.character(all.data.nights$dew.pt))


#summarize subsets
all.data.summary.days <- ddply(all.data.days, c("chamber"), summarise,
                               time.period=c("day"),
                               mean.temp = mean(temp, na.rm=TRUE),
                               sd.temp = sd(temp, na.rm=TRUE),
                               mean.RH = mean(RH, na.rm=TRUE),
                               sd.RH   = sd(RH, na.rm=TRUE),
                               temp.offset.adj=(mean(temp, na.rm=TRUE)-22),
                               RH.offset.adj=(mean(RH, na.rm=TRUE)-62))

all.data.summary.nights <- ddply(all.data.nights, c("chamber"), summarise,
                                 time.period=c("night"),
                                 mean.temp = mean(temp, na.rm=TRUE),
                                 sd.temp = sd(temp, na.rm=TRUE),
                                 mean.RH = mean(RH, na.rm=TRUE),
                                 sd.RH   = sd(RH, na.rm=TRUE),
                                 temp.offset.adj=(mean(temp, na.rm=TRUE)-22),
                                 RH.offset.adj=(mean(RH, na.rm=TRUE)-62))


#combine subsets
all.data.summary=rbind(all.data.summary.days, all.data.summary.nights)

#round values appropriately, temp adjusts by 0.1 degree, RH adjusts by 1%
all.data.summary[,3:7] <-round(all.data.summary[,3:7],1) 
all.data.summary[,8] <-round(all.data.summary[,8],0) 



# for (i in 1:length(obj.names)) {
#   
#   #subset each dataframe by night and day
#   df=get(as.character(obj.names[i]))
#   XTSDATA <- xts(df[, -6], df[, 6])
#   days=XTSDATA["T08:30:00/T16:30:00"]
#   nights=XTSDATA["T16:30:00/T08:30:00"]
#   
#   #store day and night time temp/RH means
#   day.temp=mean(as.numeric(days$temp), na.rm=TRUE)
#   day.temp.sd=sd(as.numeric(days$temp), na.rm=TRUE)
#   night.temp=mean(as.numeric(nights$temp), na.rm=TRUE)
#   
#   day.rh=mean(as.numeric(days$RH), na.rm=TRUE)
#   night.rh=mean(as.numeric(nights$RH), na.rm=TRUE)
# }

write.csv(all.data.summary, file="summary_and_offsets_results.csv")

library(gridExtra)
pdf("summary_and_offsets_results.pdf", height=11, width=8.5)
grid.table(all.data.summary)
dev.off()
