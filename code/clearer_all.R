setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")
library(tidyr)
library(qdapRegex)

votes <- read.csv("data2all.csv", header=T)
votes$date <- sapply(votes$date, as.character)
votes <- separate(votes, date, c("weekday","monthday","yeartime"), sep = '/ ')
votes <- separate(votes, monthday, c("month", "day"), sep = " ")
votes <- separate(votes, yeartime, c("year","time"), sep = 4)
votes$datec <- as.Date(paste(votes$month,votes$day,votes$year),format = "%B %d %Y")

votes$description <- sapply(votes$description, as.character)
votes$description <- rm_white(votes$description)
votes <- separate(votes, description, c("type","extra"), sep = " ", extra = "merge")

roll <- votes[votes$type == "ROLL",]
consent <- votes[votes$type == "CONSENT",]
votesFIN <- votes[(votes$type != "ROLL" & votes$type != "CONSENT"),]

cols <- colnames(votesFIN)
sens <- cols[c(8:(length(cols)-1))]
years <- unique(votesFIN$year)
inc1 <- 1

for (k in years){
  
  votesyear <- votesFIN[votesFIN$year == k,]
  justvotes <- votesyear[,sens]
  jvY <- (justvotes == 'Y')*1
  jvN <- (justvotes == 'N')*1
  jvNV <- (justvotes == 'NV')*1
  jvYN <- jvY + jvN
  
  votesyear$DEM <- (rowSums(jvY) > 19)*1
  against <- data.frame(colSums(votesyear$DEM*jvN+(1-votesyear$DEM)*jvY)/colSums(jvYN))
  colnames(against) <- c(paste0("VotesAgainst",k))
  
  if (inc1 == 1){
    againstall <- against
  }else{
    againstall <- cbind(againstall,against)
  }
  
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
  
  if (inc1 == 1){
    outputall <- output
  }else{
    outputall <- cbind(outputall,output[,3])
  }
  
  inc1 <- inc1 + 1
}

colnames(outputall) <- c("Senator1","Senator2",
                         "Weight2003","Weight2004","Weight2005",
                         "Weight2006","Weight2007","Weight2008","Weight2009",
                         "Weight2010","Weight2011","Weight2012","Weight2013",
                         "Weight2014","Weight2015","Weight2016","Weight2017")

rownames(againstall) <- tolower(rownames(againstall))

write.csv(againstall,"votesagainstall.csv")

outputall$Senator1 <- tolower(outputall$Senator1)
outputall$Senator2 <- tolower(outputall$Senator2)

write.csv(outputall,"senator_pairsall.csv",row.names = F)


#################################
#################################
#################################
#Extra stuff

# outmat <- data.frame(matrix(0,nrow = length(sens), ncol = length(sens)))
# 
# for (i in c(1:length(sens))) {
#   for (j in c(1:length(sens))) {
#     YY <- jvY[,i]%*%jvY[,j] + jvN[,i]%*%jvN[,j]
#     NN <- jvY[,i]%*%jvN[,j] + jvN[,i]%*%jvY[,j]
#     outmat[i,j] <- YY/(YY+NN)
#   }
# }
# 
# colnames(outmat) <- sens
# rownames(outmat) <- sens

# minmaxdates <- data.frame(matrix(0, nrow = length(sens), ncol = 3))
# 
# for (i in c(1:length(sens))){
#   minmaxdates[i,1] <- sens[i]
#   minmaxdates[i,2] <- as.Date(min(votesFIN[jvYN[,i] == 1,"datec"]))
#   minmaxdates[i,3] <- as.Date(max(votesFIN[jvYN[,i] == 1,"datec"]))
# }
# 
# minmaxdates$X2 <- as.Date(minmaxdates$X2,origin = "1970-01-01")
# minmaxdates$X3 <- as.Date(minmaxdates$X3,origin = "1970-01-01")
# colnames(minmaxdates) <- c("Senator","FirstDate","LastDate")

#write.csv(minmaxdates,"minmaxdates.csv",row.names = F)

#extras
# library(heatmaply)
# heatmaply(normalize(outmat))
# heatmaply(percentize(outmat))

# vExtra <- votesFIN
# vExtra$yay <- rowSums(jvY)
# 
# fails <- votesFIN[which(rowSums(jvY)<20),]
