##========================================
## Linear mixed-effect model (with trend)
##========================================

rm(list=ls())

library(lmerTest)

load('Simulated_data.RData')

Treatments <- c('Tr1', 'Tr2') ## choose treatments to compare
Start_Day <- 6 ## first day number of the selected period
End_Day <- 20 ## last day number of the selected period
##-----------------------------------------------------------------
Data <- droplevels(subset(Data, is.element(Treatment, Treatments)))
Data <- droplevels(subset(Data, Timepoint >= Start_Day & Timepoint <= End_Day))
Data <- within(Data, Treatment <- relevel(Treatment, ref = 'Tr1')) ## choose Tr1 as baseline
Data <- transform(Data, Timepoint=as.factor(Timepoint))
Data <- transform(Data, Timepoint_ordered=as.numeric(Timepoint))
##-------------------------------------------------------------------------
Model <- lmer(Response ~ 1 + Timepoint_ordered * Treatment + (1|No), data=Data)        
summary(Model)

##--------------------------------------------
## Plot fixed-effect model outcomes (optional)
##--------------------------------------------
library(ggplot2)

beta <- fixef(Model)
a <- length(Treatments[2:length(Treatments)]) ## Number of investigated treatment lines (here only one treament selected)
b <- length(beta)

intercepts <- c(beta[1], beta[1] + beta[3:(3+a-1)]) 
slopes <- c(beta[2], beta[2] + beta[(b-a+1):b])

params <- data.frame(a=intercepts, b=slopes, Treatment=levels(Data $ Treatment))

Data $ Fit <- fitted(Model, level=0)

ggplot(Data, aes(x=Timepoint_ordered, y=Fit, group=id, col=Treatment)) +
  geom_point() + 
  geom_line(lty=3) + 
  geom_abline(data=params, aes(intercept=a, slope=b, col=Treatment),size=1.5) +
  scale_x_continuous(breaks = unique(Data $ Timepoint_ordered)) +
  ylab('Model fit') +
  xlab('\n Timepoint (ordered)')
