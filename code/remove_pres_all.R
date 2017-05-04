setwd("/Users/nathanmeyers/Documents/bigdatafinal/data/")

library('stringr')
library('data.table')

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
votes2 <- votes2[ , !(names(votes2) %in% c("Test.member","Lynch.prata"))]

setnames(votes2, old = c("Da.ponte","Paiva.weed","O.neill","Cool.rumsey","Description","Date"), 
         new = c("Ponte","Weed","Neill","Rumsey","description","date"))

madprez <- votes2[votes2$Madam.president != "N/A",]
mrprez <- votes2[votes2$Mr..President != "N/A",]

votes2[votes2[,"Ruggerio"] == "N/A","Ruggerio"] <- votes2[votes2[,"Ruggerio"] == "N/A","Mr..President"]
votes2[votes2[,"Weed"] == "N/A","Weed"] <- votes2[votes2[,"Weed"] == "N/A","Madam.president"]
votes2 <- votes2[,-c(which(colnames(votes2)=="Mr..President"),which(colnames(votes2)=="Madam.president"))]

write.csv(votes2,"data2all.csv", row.names = F)