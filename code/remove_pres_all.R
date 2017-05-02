setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")

library('stringr')

votes <- read.csv("data-all.csv", header = T, stringsAsFactors=FALSE)
votes2 = data.frame(votes)
votes2[votes2 == "n"] <- "N"
votes2[votes2 == "y"] <- "Y"
votes2[votes2 == "E"] <- "N/A"

#Attributes all votes by Mr. Presient to Ruggerio and
#all votes by Madam President to Paiva.Weed

proper <- c('Bates',
            'Ciccone',
            'Cote',
            'Crowley',
            'Da.Ponte',
            'DiPalma',
            'Doyle',
            'Felag',
            'Fogarty',
            'Gallo',
            'Goodwin',
            'Hodgson',
            'Jabour',
            'Kettle',
            'Lombardo',
            'Lynch',
            'McCaffrey',
            'Metts',
            'Miller',
            'Nesselbush',
            'O.Neill',
            'Ottiano',
            'Paiva.Weed',
            'Picard',
            'Pichardo',
            'Raptakis',
            'Ruggerio',
            'Sheehan',
            'Sosnowski',
            'Walaska')

upper <-c('BATES',
          'CICCONE',
          'COTE',
          'CROWLEY',
          'DaPONTE',
          'DiPALMA',
          'DOYLE',
          'FELAG',
          'FOGARTY',
          'GALLO',
          'GOODWIN',
          'HODGSON',
          'JABOUR',
          'KETTLE',
          'LOMBARDO',
          'LYNCH',
          'McCAFFREY',
          'METTS',
          'MILLER',
          'NESSELBUSH',
          'O.NEILL..E.',
          'OTTIANO',
          'PAIVA.WEED',
          'PICARD',
          'PICHARDO',
          'RAPTAKIS',
          'RUGGERIO',
          'SHEEHAN',
          'SOSNOWSKI',
          'WALASKA')

for (i in c(1:(length(proper)))){
  votes2[votes2[,proper[i]] == "N/A",proper[i]] <- votes2[votes2[,proper[i]] == "N/A",upper[i]]
}

votes2 <- votes2[ , !(names(votes2) %in% upper)]
colnames(votes2) <- str_to_title(colnames(votes2))
votes2[votes2[,"Lynch"] == "N/A","Lynch"] <- votes2[votes2[,"Lynch"] == "N/A","Lynch.prata"]
colnames(votes2[,c("Da.ponte","Paiva.weed","O.neill","Cool.rumsey" )]) <- c("Ponte","Weed","Neill","Rumsey")
votes2 <- votes2[ , !(names(votes2) %in% c("Test.member","Lynch.prata"))]





"TEST.MEMBER"   
#########3
votes2[votes[,"Ruggerio"] == "N/A","Ruggerio"] <- votes[votes[,"Ruggerio"] == "N/A","Mr..President"]
votes2[votes[,"Paiva.Weed"] == "N/A","Paiva.Weed"] <- votes[votes[,"Paiva.Weed"] == "N/A","Madam.President"]
votes2 <- votes2[,-c(which(colnames(votes2)=="Mr..President"),which(colnames(votes2)=="Madam.President"))]





#write.csv(votes2,"data2.csv", row.names = F)