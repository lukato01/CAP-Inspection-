#!/usr/bin/env Rscript --vanilla

suppressMessages(library(gdata))

datemapfile <- "datemap.csv"
#mycwd <- "/Users/olgalukatskaya/Desktop/tempfolder"
mycwd <- "/sc/orga/projects/NIPT/data/scratch/CAP"
mmonths <- c("9.17", "10.17", "11.17", "12.17", "1.18", "2.18", "3.18", "4.18", "5.18", "6.18", "7.18", "8.18", "9.18")

setwd(mycwd)
# read the sample->month mapping csv
month_map <- read.csv(paste(mycwd, "/", datemapfile,  sep=""))

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

myDebug <- function(p1, p2){
  print(p1)
  print("***************")
  print("***************")
  print("***************")
  print("***************")
  print(p2)
}

# loop for each month
for(i in 1:length(mmonths)) {
  month_df <- subset(month_map, mon_yr == mmonths[i])
  month_df$Run<-as.character(month_df$Run)

  started_summary <- FALSE
  
  # loop for samples in each month
  for(j in 1:nrow(month_df)) {
    sample_name <- month_df[j,1]
    
    #result = tryCatch({
      
      # if sample_name begins with CT
      # find the folder that begins with CT and ends with those 3 digits
      # set sample_name to that folder
      #sample_name <- "CT939" # "CT-8026775939"
      if (startsWith(sample_name, "CT")) {
        last3 = substrRight(sample_name, 3)
        mypat = paste("^./CT.*", last3, sep="")
        mdirs <- list.dirs(recursive = FALSE)
        mdirs <- mdirs[ grepl(mypat, mdirs) ]
        sample_name <- substring(mdirs[1],3)   # substring(mdirs[i],3)
      }
      
      path <- paste(mycwd, "/", sample_name, sep="") # "/sc/orga/projects/NIPT/data/scratch/CAP/B2671"
      #setwd(path)
      csv_name_fullpath <- paste(path, "/", sample_name, ".csv",  sep="")
      
      if(file.exists(csv_name_fullpath)) { # Check if appropriate CSV is in this folder, skip the rest of the execution in this loop iteration if not
        # read this samples csv file that contains its Mean
        this_samples_csv_df <- read.csv(csv_name_fullpath)
        
        if (!started_summary) { # need to start df that adds on all the samples summaries
          total_df <- this_samples_csv_df
          started_summary <- TRUE
        } else {
          #myDebug(total_df, this_samples_csv_df)
          result = tryCatch({
            total_df <- merge(total_df, this_samples_csv_df, by='x',all = FALSE, sort = FALSE)
          }, error = function(e) {
          }, finally = {
          })
        }
      }
    
    #}, error = function(e) {
    #}, finally = {
    #})
  }
  
  ### Do the means stuff
  #result = tryCatch({
    mon_mean_df<-data.frame(x=total_df[,1], Means=rowMeans(total_df[,-1])) 
    mon_mean_df<-rename.vars( mon_mean_df, c("Means") , mmonths[i])
  #}, error = function(e) {
  #}, finally = {
  #  print(total_df)
  #})
  
  ## Write the CSV with the added  
  write_to_filename <-  paste(mycwd, "/", "res_", mmonths[i], ".csv", sep="")
  write.csv(mon_mean_df, file=write_to_filename, row.names = FALSE)
  print("wrote the month mean")
  print(write_to_filename)
 
}

