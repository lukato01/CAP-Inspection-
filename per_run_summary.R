#!/usr/bin/env Rscript --vanilla

#mycwd <- "/Users/olgalukatskaya/Desktop"
mycwd <- "/sc/orga/projects/NIPT/data/scratch/CAP"

setwd(mycwd)
mdirs <- list.dirs(recursive = FALSE) # lists all the directories
#mdirs <- mdirs[ grepl("^./B", mdirs) ]
  
suppressMessages(library(gdata))

cbind.all <- function (...)
{
  nm <- list(...)
  nm <- lapply(nm, as.matrix)
  n <- max(sapply(nm, nrow))
  do.call(cbind, lapply(nm, function(x) rbind(x, matrix(, n -
                                                          nrow(x), ncol(x)))))
}

# For loop here
for(i in 1:length(mdirs)) {
  
  sample_name <- substring(mdirs[i],3)
  path <- paste(mycwd, "/", sample_name, sep="") # "/sc/orga/projects/NIPT/data/scratch/CAP/B2671"
  csv_name_fullpath <- paste(path, "/", sample_name, ".csv",  sep="") # "/sc/orga/projects/NIPT/data/scratch/CAP/B2671/B2671.csv"
  setwd(path)
  df_combined <- data.frame()
  file.names <- dir(path, pattern =".part1") # looking for files with .part1 anywhere in the file name 
  
  # check that there are any .part1 files found
  if ((length(file.names)>0) && !file.exists(csv_name_fullpath)) {
    
     result = tryCatch({
      
      #remove NTC
      file.names <-Filter(function(x) !any(grepl("NTC", x)), file.names)
      for(i in 1:length(file.names)) {
        file <- read.table(file.names[i],header=TRUE, sep="\t")
        b <- as.data.frame(t(file))
        chunks <- unlist(strsplit(file.names[i], "_"))
        b <- rename.vars( b, c("V1") , c(chunks[1]))
        df_combined <- cbind.all(df_combined, b)
      }
      write.csv(df_combined, file=csv_name_fullpath)
      print("wrote")
      print(csv_name_fullpath)
      
      ### calculate mean
      # read and skip row 1 and last 3 rows
      headers = read.csv(paste(sample_name, ".csv",  sep=""), header = F, nrows = 1, as.is = T)
      df2 = read.csv(paste(sample_name, ".csv",  sep=""), skip = 2, header = F)
      colnames(df2)= headers
      df2 = head(df2,-3)
    
      # Make the means column
      just_the_mean<-data.frame(x=df2[,1], Means=rowMeans(df2[,-1])) 
      just_the_mean<-rename.vars( just_the_mean, c("Means") , sample_name)
      
      ## And again write the CSV with the added  
      write.csv(just_the_mean, file=csv_name_fullpath, row.names = FALSE)
      print("wrote the thing with just the mean column")
      print(csv_name_fullpath)
      
      
    }, error = function(e) {
    }, finally = {
    })

  } else {# end of if checking for file.names length
    print(sample_name)
    print("did not have any .part1")
  }
} # end of for





