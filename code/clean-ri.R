#######################################################################
# This script reshapes the RI data so we can calculate inter-senator
# weights and parities.
#######################################################################

setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")
library(tidyr)
library(qdapRegex)

#Reformats date and description
votes <- read.csv("votes-ri.csv", header=T)
votes$date <- sapply(votes$date, as.character)
votes <- separate(votes, date, c("weekday","monthday","yeartime"), sep = '/ ')
votes <- separate(votes, monthday, c("month", "day"), sep = " ")
votes <- separate(votes, yeartime, c("year","time"), sep = 4)
votes$datec <- as.Date(paste(votes$month,votes$day,votes$year),format = "%B %d %Y")

votes$description <- sapply(votes$description, as.character)
votes$description <- rm_white(votes$description)
votes <- separate(votes, description, c("type","extra"), sep = " ", extra = "merge")

#We only want the non-roll and non-consent votes. Hopefully, future iterations
#will remove even more unnecessary votes.
roll <- votes[votes$type == "ROLL",]
consent <- votes[votes$type == "CONSENT",]
votesFIN <- votes[(votes$type != "ROLL" & votes$type != "CONSENT"),]

#Generate a list of all the senators and all of the years in the data
cols <- colnames(votesFIN)
sens <- cols[c(8:(length(cols)-1))]
years <- unique(votesFIN$year)
inc1 <- 1

#Generate weights and parities for each year
for (k in years){

  #Calculate vote totals for each senator
  votesyear <- votesFIN[votesFIN$year == k,]
  justvotes <- votesyear[,sens]
  jvY <- (justvotes == 'Y')*1
  jvN <- (justvotes == 'N')*1
  jvYN <- jvY + jvN

  #Only include senators who voted at least 20 times in the data
  notpres <- c(colSums(jvYN) < 20)

  jvY[,notpres] <- 0
  jvN[,notpres] <- 0
  jvYN[,notpres] <- 0

  #Determin parity by how many times the senator voted against the majority
  votesyear$DEM <- (rowSums(jvY) > 19)*1
  against <- data.frame(colSums(votesyear$DEM*jvN+(1-votesyear$DEM)*jvY)/colSums(jvYN))
  colnames(against) <- c(paste0("VotesAgainst",k))

  #Merge results of each year together
  if (inc1 == 1){
    againstall <- against
  }else{
    againstall <- cbind(againstall,against)
  }

  #Calculate weights between each pair of senators
  output <- data.frame(matrix(0,nrow = (length(sens)*(length(sens)-1)/2), ncol = 4))
  inc <- 1

  for (i in c(1:(length(sens)-1))) {
    for (j in c((i+1):length(sens))) {
      output[inc,1] <- sens[i]
      output[inc,2] <- sens[j]
      output[inc,3] <- jvY[,i]%*%jvY[,j] + jvN[,i]%*%jvN[,j]
      output[inc,4] <- jvY[,i]%*%jvN[,j] + jvN[,i]%*%jvY[,j]
      inc <- inc + 1
    }
  }

  colnames(output) <- c("Senator1","Senator2","Agree","Disagree")
  output$weight <- output$Agree/(output$Agree+output$Disagree)
  colnames(output) <- c("Senator1","Senator2","Agree","Disagree",paste0("Weight",k))
  output <- output[,c(1,2,5)]

  #Merge results of each year together
  if (inc1 == 1){
    outputall <- output
  }else{
    outputall <- cbind(outputall,output[,3])
  }

  inc1 <- inc1 + 1
}

#Rename all columns in the data set
colnames(outputall) <- c("Senator1","Senator2",
                         "Weight2003","Weight2004","Weight2005",
                         "Weight2006","Weight2007","Weight2008","Weight2009",
                         "Weight2010","Weight2011","Weight2012","Weight2013",
                         "Weight2014","Weight2015","Weight2016","Weight2017")

#Lowercase names to standardize for merging
rownames(againstall) <- tolower(rownames(againstall))
outputall$Senator1 <- tolower(outputall$Senator1)
outputall$Senator2 <- tolower(outputall$Senator2)

#Output csvs
write.csv(againstall,"parity-ri.csv")
write.csv(outputall,"weights-ri.csv",row.names = F)
