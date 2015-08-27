#Read the data and transform them to spatial objects:
nowcastLocs <- summaryBy(LongNowCast + LatNowCast ~ GeneralLoc, data=Nowcast, FUN=mean)

coordinates(nowcastLocs) <- ~LongNowCast.mean+LatNowCast.mean
coordinates(Coords) <- ~Longitude+Latitude
#Now calculate pairwise distances between points
d <- gDistance(nowcastLocs,Coords, byid=T)
d <- as.data.frame(d)
colnames(d) <- nowcastLocs$GeneralLoc
d$Site <- Coords$Site

result <- t(sapply(seq(nrow(d)), function(i) {
  j <- which.min(d[i,])
  c(paste(colnames(d)[j], sep='/'), d[i,j])
}))

result<- as.data.frame(result)
result$Site <- d$Site
names(result)[names(result)=="V1"] <- "NowCastLoctoJoin"

withBT <- join(withBT, result[,c(1,3)], by="Site", type="left", match="first")
rm(d,result,nowcastLocs, Coords)

names(sumAll)[names(sumAll)=="GeneralLoc"] <- "NowCastLoctoJoin"

sumAll$Date<- as.Date(sumAll$Date)
withBT$Date<- as.Date(withBT$Date)

withNowcast<- join(withBT, sumAll, by=c("NowCastLoctoJoin","Date"), type="left")

#remove extra columns created by merge with video and BT
withNowcast <- withNowcast[ , -which(names(withNowcast) %in% c("NowCastLoctoJoin"))] 

rm(sumAll, withBT, WaterVel,WavesVel,Nowcast,DAvWaterVel)
