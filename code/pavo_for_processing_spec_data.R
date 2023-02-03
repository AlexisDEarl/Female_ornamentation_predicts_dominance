rm(list=ls())

#load in pavo package - install it first with the following code:
#install.packages("pavo", dependencies=T)
library(pavo)

#setting working directory to where the spec files are all held - having the files in sub folders is ok
setwd("/Volumes/AEARL_1/Peahen_Ornamentation_Project/MastersProject_PeahenFeatherMeasurements_SpecFiles/Data")

#loading in the spec files
specs <- getspec(getwd(), ext="txt", subdir=T, subdir.names = F, lim=c(300,700))

#taking a quick look at the first 10 to make sure they look ok
explorespec(specs[,1:10])

#This plots the first 3 specs with four different smoothing functions
#Want the curve not to be noisy but do not want to over smooth it either
plotsmooth(specs[1:4], minsmooth=0.05, maxsmooth = 0.5, curves = 4, ask=FALSE)

#it looks like the smoothing span of 0.2 works
#this code processes the specs to smooth them and removes any negative reflectance values and replaces them with zero
pspecs <- procspec(specs, opt="smooth", span=0.2, fixneg = "zero")

#this runs the visual model on the spec data, which converts the spectral curves into relative cone stimulations for the avian visual system, specifically the peafowl color vision and achromatic vision
vismod1 <- vismodel(pspecs, visual="pfowl", achromatic="ch.dc", illum="ideal")
# Then need to convert these cone stimulations into avian tetrahedral colorspace
phen.col <- colspace(vismod1)
# now pull out the color variables
#hue theta = red-green-blue hue (i.e., hue in the human visible portion of the spectrum)
#hue phi = how much UV is present (i.e., hue in the UV portion of the spectrum)
#r.achieved = chroma
#lum = luminance / brightness


head(phen.col)
class(phen.col)

phen.col$ID <- rownames(phen.col)

library(dplyr)
library(tidyr)

phen.col$FileName<-phen.col$ID
phen.col<-phen.col %>% separate(ID,
                c("PeahenID", "BodyRegion","FeatherNumber", "IlluminationAngle"))
head(phen.col)

write.csv(phen.col,"RawData_pavo.csv")
