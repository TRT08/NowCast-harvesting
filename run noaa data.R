setwd("F:/DATA/SLBE/R scripts/Mass download NowCast Data/")

source("getnoaa.R")

library(plyr)

sites2 <- read.csv("sitesnew.csv")
sites <- read.csv("need4.csv")
trips <- read.csv("trips.csv")
random <- read.csv("random.csv")

sites$newdate <- strptime(as.character(sites$DateIn), "%m/%d/%Y")
sites$startdate <- format(sites$newdate, "%Y-%m-%d")

sites$newdate2 <- strptime(as.character(sites$DateOut), "%m/%d/%Y")
sites$enddate <- format(sites$newdate2, "%Y-%m-%d")

sites <- sites[ , -which(names(sites) %in% c("newdate2","newdate", "DateIn", "DateOut"))]

sites <- join(sites, sites2, by="Site")

################

random$newdate <- strptime(as.character(random$startdate), "%m/%d/%Y")
random$startdate <- format(random$newdate, "%Y-%m-%d")

random$newdate2 <- strptime(as.character(random$enddate), "%m/%d/%Y")
random$enddate <- format(random$newdate2, "%Y-%m-%d")

random <- random[ , -which(names(random) %in% c("newdate2","newdate"))]

sites <- random
#when ready, use this
#sites <- random

#lake=huron&i=-83.2104&j=45.3984&v=depth,eta,uc,vc,utm,vtm,wvh,wvd,wvp,ci,hi&st=2014-12-01:00:00:00&et=2014-12-17:00:00:00&u=e&order=asc&pv=1&doy=1&tzf=-5&f=csv'
#lake=michigan&i=-86.5283&j=45.251&v=depth,air_u,air_v,cl,at,dp&in=1&st=2014-12-01:00:00:00&et=2014-12-16:00:00:00&u=e&order=asc&pv=1&doy=1&tzf=-5&f=csv

# Nowcast 2D ##################################################################
# pre-allocate list
l <- vector(mode='list', length=length(nrow(sites)*30))

#i in 1:nrow(sites)
#for (i in 1:nrow(sites))
for (i in 1:nrow(sites)){
  print(c((sites[i, "enddate"]),(sites[i, "Latitude"])))
  
  l[[i]] <- Nowcast2d('michigan', sites[i, "Longitude"], sites[i, "Latitude"], 'depth,eta,uc,vc,utm,vtm,wvh,wvd,wvp,ci,hi', sites[i, "startdate"], sites[i, "enddate"])
}

# stack elements of list into DF, filling missing columns with NA
g <- ldply(l)

#randomsitesnowcast2d<- rbind.fill(g)

# save to CSV
#write.csv(randomsitesnowcast2d, "scouts2D2.csv", row.names=FALSE)


# Nowcast Input data ##################################################################
# pre-allocate list
k <- vector(mode='list', length=length(nrow(sites)*30))
for (i in 1:nrow(sites)){
  print(c((sites[i, "enddate"]),(sites[i, "Latitude"])))
  
  k[[i]] <- NowcastInput('michigan', sites[i, "Longitude"], sites[i, "Latitude"], 'depth,air_u,air_v,cl,at,dp', sites[i, "startdate"], sites[i, "enddate"])
}

# stack elements of list into DF, filling missing columns with NA
t <- ldply(k)

#NowcastInput<- rbind.fill(t)

# save to CSV
#write.csv(NowcastInput, "scoutsInput1.csv", row.names=FALSE)

#################Merge the two####################
FS2D <- read.csv("FixedSitesNowcast2ds.csv" )
FSIn <- read.csv("FixedSitesNowcastInput.csv" )
RS2D <- read.csv("RandomSitesNowcast2d.csv" )
RSIn <- read.csv("RandomSitesNowcastInput.csv" )

############
#Add in the missing data

setwd("F:/DATA/SLBE/R scripts/Mass download NowCast Data/miss")
data <- lapply(dir(),read.table, header = T, skip = 4, sep=",")
df <- do.call("rbind", data)
rm(data)
df[df == -9999] <- NA 

#############



CF<- read.csv("F:/DATA/SLBE/NowCast Data/CombinedFixedSites.csv")

FixedSites <- join(g,t, by=c("Date.Time.GMT.0500.","Lat","Long"), type="full",match="first")
#RandomSites <- join(RS2D,RSIn, by=c("Date.Time.GMT.0500.","Lat","Long"), type="full")

sites <- sites[,c(1,4,5)]
sites <- sites[!duplicated(sites), ]

names(FixedSites)[2:3]<- c("Latitude","Longitude")
Fix <- join(FixedSites,sites,by=c("Latitude","Longitude"), match="first")

FSIn2<- rbind.fill(CF,Fix)

#FSIn2 <- FSIn2[!duplicated(FSIn2), ]
#FSIn2 <- FSIn2[!apply(FSIn2[,22:24],1,function(x) {all(is.na(x))} ),]

write.csv(FSIn2, "F:/DATA/SLBE/NowCast Data/CombinedFixedSites2.csv")
write.csv(FixedSites, "scouts2.csv")

NC <- read.csv("F:/DATA/SLBE/NowCast Data/CombinedFixedSites2.csv")
names(NC)
names(sites)[10:11]<- c("Lat","Long")

sites3 <- join(sites, NC, by=c("Site"), type = "left" ,match="first")