## Example command input should be:
## Rscript clean-mt2.R "mt" "/Users/nathanmeyers/Documents/parity-in-the-senate/code"

#Take command line arguments
args <- commandArgs(trailingOnly = TRUE)
state <- args[1] 
folder <- args[2]
setwd(folder)

#Load necessary libraries
library(tidyr)
library(qdapRegex)
library(lubridate)

#Read in data
votes <- read.csv(paste0("../data/",state,"/votes-",state,".csv"), header = T)
votes$date <- year(votes$date)

#Make lists of senators and years
sens <- colnames(votes)
sens <- sens[c(3:length(sens))]
years <- unique(votes$date)

#Find the number of senators in the state senate
votesF <- data.frame(votes)
votesF$count <- apply(votesF, 1, function(x) (sum(x != "N/A")-2))
numsens <- max(votesF$count)

## Calculate weights and parities for each year

inc1 <- 1
for (k in years){

  #Find yes and no votes and remove senators who have 
  #voted less than 20 times in a year
  votesyear <- votes[votes$date == k,]
  justvotes <- votesyear[,sens]
  jvY <- (justvotes == 'Y')*1
  jvN <- (justvotes == 'N')*1
  jvYN <- jvY + jvN

  notpres <- c(colSums(jvYN) < 20)

  jvY[,notpres] <- 0
  jvN[,notpres] <- 0
  jvYN[,notpres] <- 0

  #Calculate number of bills where the senators voted
  #against the majority
  votesyear$DEM <- (rowSums(jvY) > (numsens/2))*1
  against <- data.frame(colSums(votesyear$DEM*jvN+(1-votesyear$DEM)*jvY)/colSums(jvYN))
  colnames(against) <- c(paste0("VotesAgainst",k))

  #Store results
  if (inc1 == 1){
    againstall <- against
  }else{
    againstall <- cbind(againstall,against)
  }

  
  output <- data.frame(matrix(0,nrow = (length(sens)*(length(sens)-1)/2), ncol = 4))
  inc <- 1
  
  #Calculate inter-senator weights
  for (i in c(1:(length(sens)-1))) {
    for (j in c((i+1):length(sens))) {
      output[inc,1] <- sens[i]
      output[inc,2] <- sens[j]
      output[inc,3] <- jvY[,i]%*%jvY[,j] + jvN[,i]%*%jvN[,j]
      output[inc,4] <- jvY[,i]%*%jvN[,j] + jvN[,i]%*%jvY[,j]
      inc <- inc + 1
    }
  }

  #Rename and store output
  colnames(output) <- c("Senator1","Senator2","Agree","Disagree")
  output$weight <- output$Agree/(output$Agree+output$Disagree)
  colnames(output) <- c("Senator1","Senator2","Agree","Disagree",paste0("Weight",k))
  output <- output[,c(1,2,5)]

  if (inc1 == 1){
    outputall <- output
  }else{
    outputall <- cbind(outputall,output[,3])
  }
  
  inc1 <- inc1 + 1
}

#Rename columns and make all ids lowercase for merge
yearweights <- paste0("Weight",years)
colnames(outputall) <- c("Senator1","Senator2",yearweights)
rownames(againstall) <- tolower(rownames(againstall))

outputall$Senator1 <- tolower(outputall$Senator1)
outputall$Senator2 <- tolower(outputall$Senator2)

#Write to csvs
write.csv(againstall,paste0("../data/",state,"/parity-",state,".csv"))
write.csv(outputall,paste0("../data/",state,"/weights-",state,".csv"),row.names = F)