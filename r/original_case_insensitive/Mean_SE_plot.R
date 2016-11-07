##===========================
## Mean +/- SE plot
##===========================

rm(list=ls())

library(ggplot2)
library(plyr)

load('Simulated_Data.RData')

summary_mean_SE_CI <- function (data = NULL, measurevar, groupvars = NULL, na.rm = FALSE, 
                                conf.interval = 0.95, .drop = TRUE){
  require(plyr)
  length2 <- function(x, na.rm = FALSE) {
    if (na.rm) 
      sum(!is.na(x))
    else length(x)
  }
  datac <- plyr::ddply(data, groupvars, .drop = .drop, .fun = function(xx, col, na.rm) {
    c(N = length2(xx[, col], na.rm = na.rm), mean = mean(xx[,col], na.rm = na.rm), sd = sd(xx[, col], na.rm = na.rm))
  }, measurevar, na.rm)
  datac <- rename(datac, c(mean = measurevar))
  datac$se <- datac$sd/sqrt(datac$N)
  ciMult <- qt(conf.interval/2 + 0.5, datac$N - 1)
  datac$ci <- datac$se * ciMult
  return(datac)
}


dfc <- summary_mean_SE_CI(Data, measurevar="Response", groupvars=c("Treatment","Timepoint"), na.rm=T)
pd <- position_dodge(.4) ## jittering
p <- ggplot(dfc, aes(x=Timepoint, y=Response, colour=Treatment, group=Treatment)) +
  geom_errorbar(aes(ymin=Response-se, ymax=Response+se), width=.8, lwd=1.1, position=pd) +
  geom_line(position=pd, lwd=1.1) +
  geom_point(position=pd, size=3) +
  scale_x_continuous(breaks = unique(Data $ Timepoint)) +
  ## scale_y_continuous(limits = c(from, to)) +
  ylab('Mean +/- SE') +
  xlab(paste0('\n Timepoint (Days)')) +
  ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
print(p)
