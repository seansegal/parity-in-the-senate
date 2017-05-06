setwd("/Users/nathanmeyers/Desktop/MONTANA/")

library(stringi)
library(lubridate)

bills <- read.csv("mt_bills.csv", stringsAsFactors = F, header=T)
bill_votes <- read.csv("mt_bill_votes.csv", stringsAsFactors = F, header=T)
legis_votes <- read.csv("mt_bill_legislator_votes.csv", stringsAsFactors = F, header = T)

sen_bills <- bills[bills$chamber == "upper",c("bill_id","title")]

sen_bill_votes <- bill_votes[(bill_votes$chamber == "upper") & (bill_votes$vote_chamber == "upper"),]
vote_ids <- unique(sen_bill_votes$vote_id)

sen_legis_votes <- legis_votes[legis_votes$vote_id %in% vote_ids,]
leg_id_index <- unique(sen_legis_votes[,c("leg_id","name")])
sen_legis_votes <- sen_legis_votes[,c("vote_id","leg_id","vote")]

#x <- table(paste(sen_legis_votes$vote_id,sen_legis_votes$leg_id,sen_legis_votes$name))

sen_legis_votesw <- reshape(sen_legis_votes, idvar = "vote_id", timevar = "leg_id", direction = "wide")
colnames(sen_legis_votesw) <- stri_sub(colnames(sen_legis_votesw),6)
sen_legis_votesw[sen_legis_votesw=='yes'] <- "Y"
sen_legis_votesw[sen_legis_votesw=='no'] <- "N"

bill_date <- bill_votes[,c("vote_id","date")]
colnames(bill_date) <- c("id","date")

votesFIN <- merge(bill_date,sen_legis_votesw,by = 'id')

cols <- colnames(votesFIN)
sens <- cols[c(3:length(cols))]
years <- unique(year(as.Date(votesFIN$date)))
votesFIN$date <- year(as.Date(votesFIN$date))
inc1 <- 1

for (k in years){
  
  votesyear <- votesFIN[votesFIN$date == k,]
  justvotes <- votesyear[,sens]
  justvotes[is.na(justvotes)] <- 0
  jvY <- (justvotes == 'Y')*1
  jvN <- (justvotes == 'N')*1
  jvYN <- jvY + jvN
  
  notpres <- c(colSums(jvYN) < 5)
  
  jvY[,notpres] <- 0
  jvN[,notpres] <- 0
  jvYN[,notpres] <- 0
  
  votesyear$DEM <- (rowSums(jvY) > 25)*1
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
  print(inc1)
}

yearweights <- paste0("Weight",years)
colnames(outputall) <- c("Senator1","Senator2",yearweights)

rownames(againstall) <- tolower(rownames(againstall))

outputall$Senator1 <- tolower(outputall$Senator1)
outputall$Senator2 <- tolower(outputall$Senator2)

leg_id_index$leg_id <- tolower(leg_id_index$leg_id)

write.csv(againstall,"parity-mt.csv")
write.csv(leg_id_index,"id_name-mt.csv")
write.csv(outputall,"weights-mt.csv",row.names = F)


