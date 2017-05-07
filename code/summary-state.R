## Rscript summary-state.R "mt" "/Users/nathanmeyers/Documents/parity-in-the-senate/code"

args <- commandArgs(trailingOnly = TRUE)

state <- args[1] 
folder <- args[2]

state <- "al"
folder <- "/Users/nathanmeyers/Documents/parity-in-the-senate/code"

setwd(folder)

library(jsonlite)
info <- fromJSON(paste0("../data/",state,"/senator-info-",state,".json"), flatten=TRUE)

if (state == "ri"){
  offset = 3
}else{
  offset = 2
}

grepl("parities.", )

years = sort(substr(colnames(info[,c(3:(length(info)-offset))]),10,13))
if (length(years) == 0){
  years = "2017"
}

out <- matrix(0,nrow = length(years),ncol = 4)
colnames(out) <- c("Dem","Rep","Ind","Unk")
rownames(out) <- years

for (k in years){
  infoyear <- info[!is.na(info[,paste0("parities.",k)]),"info.party"]
  out[k,1] <- sum(infoyear == "Dem")
  out[k,2] <- sum(infoyear == "Rep")
  out[k,3] <- sum(infoyear == "Ind")
  out[k,4] <- length(infoyear) - out[k,1] - out[k,2] - out[k,3]
}

write.csv(out,paste0("../data/",state,"/summary-",state,".csv"))