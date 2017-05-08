setwd("/Users/nathanmeyers/Documents/parity-in-the-senate/data/")

votes <- read.csv("data2all.csv")

sens <- colnames(votes)
sens <- sens[c(3:length(sens))]

justvotes <- votes[,sens]
jvY <- (justvotes == 'Y')*1
hist(rowSums(jvY),main = "Yes Votes (2003-2017)", xlab = "Number of Yes Votes")
abline(v=19,col="red")



