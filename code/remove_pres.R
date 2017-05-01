setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")
votes <- read.csv("data.csv", header = T, stringsAsFactors=FALSE)
votes2 = votes

votes2[votes[,"Ruggerio"] == "N/A","Ruggerio"] <- votes[votes[,"Ruggerio"] == "N/A","Mr..President"]
votes2[votes[,"Paiva.Weed"] == "N/A","Paiva.Weed"] <- votes[votes[,"Paiva.Weed"] == "N/A","Madam.President"]
votes2 <- votes2[,-c(which(colnames(votes2)=="Mr..President"),which(colnames(votes2)=="Madam.President"))]

write.csv(votes2,"data2.csv", row.names = F)