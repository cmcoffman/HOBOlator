#this script imports all the files in a directory, it was made for the image gauge output originally
# so its assuming the files are tab-delimited you have to make a variable called "filepath" and set it to 
#the folder you want to import and source this with "local=TRUE" for it to work
#also, it makes a dataframe called "obj.to.filename" which it will leave behind translating the
#original filesnames to their new obejct names (basically with no spaces or leading numerals)

#save wd so I can put it back how it was
old.wd=getwd()

#change wd to where the files are
setwd(filepath)

#get list of files
files = c(list.files(pattern="*.txt"), list.files(pattern="*.csv"))

#change any spaces to underscores and add "data" to beginning to remove leading numbers, which R doesnt like
obj.names=paste("data", gsub(pattern=" ", replacement="_", files), sep="_")

#actually read in the files
for (i in 1:length(files)) {
  assign(obj.names[i], read.delim(files[i]))
}

#make a dataframe that translates the filesnames to their object names
obj.to.filename=data.frame(Orginal.File=files, Object.Name=obj.names)

#set wd back to normal
setwd(old.wd)

#clean up
rm(files)
rm(i)
rm(obj.names)
rm(old.wd)
#end file import code