#######################################################################
# This calculates summary statistics for the visualization. 
# Specifically:
# 1. Number of people in each party
# 2. Histogram of parities
# 3. Histogram of weights
#######################################################################

## Example input
## Rscript summary-state.R "mt" "/Users/. . ./code"

#Import necessary libraries
library(jsonlite)

#Get arguments from command line
args <- commandArgs(trailingOnly = TRUE)
state <- args[1]
folder <- args[2]
setwd(folder)

#Import the json data on senators to get party affiliation
info <- fromJSON(paste0("../data/",state,"/senator-info-",state,".json"), flatten=TRUE)

#The ri data set is formatted slightly differently
if (state == "ri"){
  offset = 3
}else{
  offset = 2
}

#Get the years, and fix data if there is only one year
years = sort(substr(colnames(info[,c(3:(length(info)-offset))]),10,13))
if (length(years) == 0){
  years = "2017"
}

#Create output data set
out <- matrix(0,nrow = length(years),ncol = 4)
colnames(out) <- c("Dem","Rep","Ind","Unk")
rownames(out) <- years

##Party counts
for (k in years){
  infoyear <- info[!is.na(info[,paste0("parities.",k)]),"info.party"]
  out[k,1] <- sum(infoyear == "Dem")
  out[k,2] <- sum(infoyear == "Rep")
  out[k,3] <- sum(infoyear == "Ind")
  out[k,4] <- length(infoyear) - out[k,1] - out[k,2] - out[k,3]
}

##Parity histogram
parity <- read.csv(paste0("../data/",state,"/parity-",state,".csv"))
years <- substr(colnames(parity[,c(2:length(parity))]),13,16)
colnames(parity) <- c("id",years)
years <- sort(years)

#Set number of bins
breaks = c(0:20)*0.05
bin_names <- paste0("pbin",c(1:(length(breaks)-1)))
histbins <- matrix(0,nrow = length(years),ncol = (length(breaks)-1))
colnames(histbins) <- bin_names

#Get bin heights for each year
for (i in c(1:length(years))){
  yr <- years[i]
  x <- hist(parity[,yr],breaks = breaks,plot = F)
  histbins[i,] <- x$counts
}

#Add results to output file
out <- cbind(out,histbins)

##Weight histogram
weights <- read.csv(paste0("../data/",state,"/weights-",state,".csv"))
years <- substr(colnames(weights[,c(3:length(weights))]),7,11)
colnames(weights) <- c("Sen1","Sen2",years)
years <- sort(years)

#Set number of bins (more bins because more weights than parities)
breaks = c(0:100)*0.01
bin_names <- paste0("wbin",c(1:(length(breaks)-1)))
histbins <- matrix(0,nrow = length(years),ncol = (length(breaks)-1))
colnames(histbins) <- bin_names

#Get bin heights for each year
for (i in c(1:length(years))){
  yr <- years[i]
  x <- hist(weights[,yr],breaks = breaks, plot = F)
  histbins[i,] <- x$counts
}

#Add results to output file
out <- cbind(out,histbins)

#write to CSV
write.csv(out,paste0("../data/",state,"/summary-",state,".csv"))
