setwd("/Users/nathanmeyers/Desktop/")
library(tidyr)
library(qdapRegex)

votes <- read.csv("data.csv", header=T)
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
jvNA <- (justvotes == 'NA')*1
jvNV <- (justvotes == 'NV')*1
jvYN <- jvY + jvN

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

write.csv(output,"senator_pairs.csv",row.names = F)

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

# library(heatmaply)
# heatmaply(normalize(outmat))
# heatmaply(percentize(outmat))

party <- data.frame(cbind(sens,1+0*c(1:length(sens))))

my.JSON <- fromJSON(file="senator-info.json")

df <- lapply(my.JSON, function(play) # Loop through each "play"
{
  # Convert each group to a data frame.
  # This assumes you have 6 elements each time
  data.frame(matrix(unlist(play), ncol=4, byrow=T))
})

# Now you have a list of data frames, connect them together in
# one single dataframe
df <- do.call(rbind, df)

colnames(df) <- names(my.JSON[[1]][[1]])
rownames(df) <- NULL

library(stringi)
df$lastname <- stri_extract_last_words(df$name)

for (i in c(1:length(sens))){
  datemin = min(votesFIN[jvYN[,i],"datec"])
  datemax = max(votesFIN[jvYN[,i],"datec"])
}

for (j in df$lastname){
  if (j != "Ponte"){
    datemin = min(votesFIN[jvYN[,j],"datec"])
    datemax = max(votesFIN[jvYN[,j],"datec"])
    print(paste(datemin,datemax))
  }
}

