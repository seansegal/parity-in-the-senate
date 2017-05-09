#######################################################################
# This script creates the histogram in the readme for RI senate 
#######################################################################

#Import votes-ri.csv
setwd("/Users/. . . /ri/")
votes <- read.csv("votes-ri.csv")

#Get all senators
sens <- colnames(votes)
sens <- sens[c(3:length(sens))]

#Find yes votes
justvotes <- votes[,sens]
jvY <- (justvotes == 'Y')*1

#Create plot
hist(rowSums(jvY),main = "Yes Votes (2003-2017)", xlab = "Number of Yes Votes")
abline(v=19,col="red")



