# Clear environment
rm(list=ls())

# Set working directory
setwd("C:/Users/alexi/Google Drive (1)/Between Computers/MastersThesis_BrightPeahensDominate/Data")

# Read in data - feathers
ALL<-read.csv("feather_data_ALL_combined.csv")

# Read in data - dominance status (normalized David's score) ####
NormDS<-read.csv("NormDS.csv")
head(NormDS)

# Combine data
ALL_norm<-merge(ALL, NormDS,by="PeahenID")
head(ALL_norm)

# Check correlations across regions of the peahen neck ornamentation for color space variables
# (correlation coefficients and p-values)

cor.test(ALL_norm$lum.avg.side,ALL_norm$lum.avg.back)
cor.test(ALL_norm$lum.avg.front,ALL_norm$lum.avg.back)
cor.test(ALL_norm$lum.avg.front,ALL_norm$lum.avg.side)

cor.test(ALL_norm$hueUV.avg.side,ALL_norm$hueUV.avg.back)
cor.test(ALL_norm$hueUV.avg.side,ALL_norm$hueUV.avg.front)
cor.test(ALL_norm$hueUV.avg.back,ALL_norm$hueUV.avg.front)

cor.test(ALL_norm$hueRGB.avg.side,ALL_norm$hueRGB.avg.back)
cor.test(ALL_norm$hueRGB.avg.side,ALL_norm$hueRGB.avg.front)
cor.test(ALL_norm$hueRGB.avg.back,ALL_norm$hueRGB.avg.front)

cor.test(ALL_norm$chroma.avg.side,ALL_norm$chroma.avg.back)
cor.test(ALL_norm$chroma.avg.side,ALL_norm$chroma.avg.front)
cor.test(ALL_norm$chroma.avg.back,ALL_norm$chroma.avg.front)

# Feathers from all regions of the neck sampled were moderately to highly correlated
# (r > 0.4,p < .04) for each color space variable except for hue UV, for which
# the front feathers were not correlated with the back or side feathers
# therefore all data is pooled going forward except hue UV front is included separately

# Next, perform information-theoretic model-averaging analysis
# to choose variables for model using Relative Importance
# calculated by summing Akaike weights for each fixed effect
library(MuMIn)
?MuMIn
library(rsq)
library(car)

# Create a global model
glm_ALL_final<-glm(NormDS~lum.avg.pooled+hueUV.avg.back.side+hueUV.avg.front+hueRGB.avg.pooled+chroma.avg.pooled+Weight,data=ALL_norm,na.action = na.fail)
summary(glm_ALL_final)

# Calculate variance-inflation factors
vif(glm_ALL_final)

# Calculate the coefficient of determination for the global model
rsq(glm_ALL_final)

# Create model selection table
d_ALL_final<-dredge(glm_ALL_final,m.lim=c(0,2))

# Calculate model-averaged parameters, along with standard errors and confidence intervals
model_ALL_vars<-model.avg(d_ALL_final,fit=T)
summary(model_ALL_vars)

# Save the component model set used to test predictors of dominance status of peahens
components_modelFinal.all_vars<-as.data.frame(model_ALL_vars$msTable)
#write.csv(components_modelFinal.all_vars,"component_model_summaries_feathersDomALL_deltamax2_domnorm_predictormax2.final.csv")

# Estimate model-averaged parameters **but only include models within 2 delta AICc from the top model**
model_ALL_final<-model.avg(d_ALL_final,subset = (delta < 2),fit=T)
summary(model_ALL_final)

# summarize and visualize data
library(data.table)

# Get summed Akaike weights for each fixed effect across the included models for relative importance (RI)
RI<-model_ALL_final$sw
RI<-as.data.frame(RI,full=TRUE)
RI<-setDT(RI, keep.rownames = "predictors")[]

# Get beta coefficients (i.e., slope)
#beta<-model_ALL_final$coefficients
beta<-as.data.frame(coefficients(model_ALL_final,full=TRUE))
beta<-setDT(beta, keep.rownames = "predictors")[]
beta = beta[-1,] #remove "(Intercept)"

# Get 95% confidence intervals (CI) for each fixed effect based on the full model average
conf95<-as.data.frame(confint(model_ALL_final,full=TRUE))
conf95<-setDT(conf95, keep.rownames = "predictors")[]
conf95 = conf95[-1,]

# create table with estimates, 95% CIs and RIs
fig3<- merge(merge(RI,beta, by = "predictors", all = TRUE ),conf95,by="predictors",all=TRUE)
fig3$RI<-round(fig3$RI,digits=2)
fig3$beta<-round(fig3$`coefficients(model_ALL_final, full = TRUE)`,digits=2)
fig3$`coefficients(model_ALL_final, full = TRUE)`<-NULL
fig3$`2.5 %`<-round(fig3$`2.5 %`,digits=2)
fig3$`97.5 %`<-round(fig3$`97.5 %`,digits=2)
fig3$confint<-paste(fig3$`2.5 %`,fig3$`97.5 %`, sep=", ")
# save results table
#write.csv(fig3, "brightness_dom_results_table.csv")

# make RI graph
library(ggplot2)
library(magrittr)
library(grid)

unique(fig3$predictors)
fig3$predictors[fig3$predictors== "Weight"] <- "Peahen Mass"
fig3$predictors[fig3$predictors== "hueUV.avg.front"] <- "Ventral Feather UV Hue"
fig3$predictors[fig3$predictors== "lum.avg.pooled"] <- "Feather Brightness *"
colnames(fig3)[2]<-"Relative_Importance"
colnames(fig3)[5]<-"Beta"

options(repr.plot.width=6, repr.plot.height=2)
plot<-ggplot(fig3, aes(x = reorder(predictors,Relative_Importance), y = Relative_Importance, main="")) +
  geom_bar(stat = "identity", width = .4, color = "black") +  theme(aspect.ratio = 1/2)+
  coord_flip() + scale_y_continuous(name="\n Relative Importance") +
  scale_x_discrete(name="") +
  geom_text(aes( label = sprintf("%.2f",Beta),y=1.05), vjust = 1, hjust = 0,size=5) +
  annotate("text", y= 1.05, x =3.5,label="Beta",hjust=0, size=6) +
  theme(plot.margin = unit(c(2,4,2,2), "cm")) +
  theme(panel.background = element_blank(),
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line = element_line(colour = 'black'),
        axis.text.x = element_text( color="black",
                                   size=16, angle=0),axis.title=element_text(size=18,color="black"),
        axis.text.y = element_text( color="black",
                                   size=17, angle=0)) + geom_hline(yintercept = .7, linetype="solid",
                                                                   color = "black", size=1)

# Code to turn off clipping
gt <- ggplotGrob(plot)
gt$layout$clip[gt$layout$name == "panel"] <- "off"
grid.draw(gt)

# save results table
results.table<-data.frame(fig3)
results.table$X2.5..<-NULL
results.table$X97.5..<-NULL
#write.csv(results.table,"results_table.csv")

# plot data points to show relationship between brightness and dominance
plot(NormDS~lum.avg.pooled,data=ALL_norm,xlab="Feather Brightness",ylab="Dominance Status (David's Score)",pch=19,col="black")
abline(glm(NormDS~lum.avg.pooled,data=ALL_norm),col="black")

# plot with ggplot
#ALL_norm$lum.avg.pooled<-round(ALL_norm$lum.avg.pooled,digits=2)
ALL_norm$fit<-predict(glm(NormDS~lum.avg.pooled,data=ALL_norm))

ALL_norm%>%ggplot(aes(x=lum.avg.pooled, y=NormDS)) + geom_point(size=2)+
  geom_smooth(aes(y=fit),color="black") +
  xlab("\n Feather Brightness")+
  ylab("Dominance Status (David's Score)\n ")+
  #theme_bw()+
  theme(panel.background = element_blank(), axis.line = element_line(colour = 'black'),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text.x = element_text(color="black", size=16, angle=0),
        axis.title = element_text(size=18,color="black"),
        axis.text.y = element_text(color="black", size=17, angle=0),
        plot.margin = margin(1,1,1,2, "cm"))+
  theme(legend.position = 'none')
