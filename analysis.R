#this script does the analysis on the files to look for temperature anomalies
#and suggest calibrations

#import data
source("data_import.R")

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
XTSDATA <- xts(all.data[, -6], all.data[, 6])
all.data.days=as.data.frame(XTSDATA["T08:30:00/T16:30:00"])
all.data.days$temp=as.numeric(as.character(all.data.days$temp))
all.data.days$RH=as.numeric(as.character(all.data.days$RH))
all.data.days$dew.pt=as.numeric(as.character(all.data.days$dew.pt))

all.data.nights=as.data.frame(XTSDATA["T16:30:00/T08:30:00"])
all.data.nights$temp=as.numeric(as.character(all.data.nights$temp))
all.data.nights$RH=as.numeric(as.character(all.data.nights$RH))
all.data.nights$dew.pt=as.numeric(as.character(all.data.nights$dew.pt))


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

all.data.summary[,3:8] <-round(all.data.summary[,3:8],1) 

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