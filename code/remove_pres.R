setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")
votes <- read.csv("data.csv", header=T, stringsAsFactors=FALSE)

votes[votes[,"Ruggerio"] == "N/A","Ruggerio"] <- votes[votes[,"Ruggerio"] == "N/A","Mr..President"]
votes[votes[,"Paiva.Weed"] == "N/A","Paiva.Weed"] <- votes[votes[,"Paiva.Weed"] == "N/A","Madam.President"]

write(votes,"data2.csv")