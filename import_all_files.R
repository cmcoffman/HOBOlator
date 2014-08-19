#this script imports all the files in a directory, it was made for the image gauge output originally
# so its assuming the files are tab-delimited you have to make a variable called "filepath" and set it to 
#the folder you want to import and source this with "local=TRUE" for it to work
#also, it makes a dataframe called "obj.to.filename" which it will leave behind translating the
#original filesnames to their new obejct names (basically with no spaces or leading numerals)


#ive modified thsi version for importing hobo datalogger outputs
#save wd so I can put it back how it was
old.wd=getwd()

#change wd to where the files are
setwd(filepath)

#get list of files
files = c(list.files(pattern="*.txt"), list.files(pattern="*.csv"))

#change any spaces to underscores and add "data" to beginning to remove leading numbers, which R doesnt like
obj.names=paste(gsub(pattern=" ", replacement="_", files), sep="_")

#this function converts to POSIX compatible time format
make.time=function(df) {
  df$real.time=as.POSIXlt(strptime(df$date.time, format="%m/%d/%Y %I:%M:%S %p"), tz="CST")
  return(df)
}



#actually read in the files
for (i in 1:length(files)) {
  assign(obj.names[i], read.csv(files[i], 
                                skip=2,
                                header=FALSE,
                                colClasses=c("numeric", "character","numeric","numeric","numeric", "NULL","NULL","NULL","NULL"),
                                col.names = c("measurement.index","date.time","temp","RH","dew.pt", "NULL","NULL","NULL","NULL"), 
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

#combine all the dataframes





#set wd back to normal
setwd(old.wd)

#clean up
rm(files)
rm(i)
#rm(obj.names)
rm(old.wd)
#end file import code