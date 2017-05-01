setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")
library(tidyr)
library(qdapRegex)

votes <- read.csv("data2.csv", header=T)
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

justvotes <- votesFIN[,sens]
jvY <- (justvotes == 'Y')*1
jvN <- (justvotes == 'N')*1
jvNV <- (justvotes == 'NV')*1
jvYN <- jvY + jvN

votesFIN$DEM <- (rowSums(jvY) > 19)*1
against <- data.frame(colSums(votesFIN$DEM*jvN+(1-votesFIN$DEM)*jvY)/colSums(jvYN))
colnames(against) <- c("VotesAgainst")
write.csv(against,"votesagainst.csv")


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

#write.csv(output,"senator_pairs.csv",row.names = F)

outmat <- data.frame(matrix(0,nrow = length(sens), ncol = length(sens)))

for (i in c(1:length(sens))) {
  for (j in c(1:length(sens))) {
    YY <- jvY[,i]%*%jvY[,j] + jvN[,i]%*%jvN[,j]
    NN <- jvY[,i]%*%jvN[,j] + jvN[,i]%*%jvY[,j]
    outmat[i,j] <- YY/(YY+NN)
  }
}

colnames(outmat) <- sens
rownames(outmat) <- sens

minmaxdates <- data.frame(matrix(0, nrow = length(sens), ncol = 3))

for (i in c(1:length(sens))){
  minmaxdates[i,1] <- sens[i]
  minmaxdates[i,2] <- as.Date(min(votesFIN[jvYN[,i] == 1,"datec"]))
  minmaxdates[i,3] <- as.Date(max(votesFIN[jvYN[,i] == 1,"datec"]))
}

minmaxdates$X2 <- as.Date(minmaxdates$X2,origin = "1970-01-01")
minmaxdates$X3 <- as.Date(minmaxdates$X3,origin = "1970-01-01")
colnames(minmaxdates) <- c("Senator","FirstDate","LastDate")

write.csv(minmaxdates,"minmaxdates.csv",row.names = F)

#extras
# library(heatmaply)
# heatmaply(normalize(outmat))
# heatmaply(percentize(outmat))

vExtra <- votesFIN
vExtra$yay <- rowSums(jvY)

fails <- votesFIN[which(rowSums(jvY)<20),]
