##===========================
## LOESS plot
##===========================

rm(list=ls())

library(ggplot2)
load('Simulated_Data.RData')

.theme <- theme(
  axis.line = element_line(colour = 'black', size = .75),
  ##panel.background = element_blank(),
  plot.background = element_blank(),
  axis.text=element_text(size=15),
  axis.title=element_text(size=17),
  legend.text=element_text(size=15), 
  legend.title=element_text(size=15), 
  plot.title=element_text(size=20)
)

p <- ggplot(Data, aes(x=Timepoint, y=Response, group=No, col=Treatment)) +
  geom_point(size=1.9) + geom_line(lty=1, lwd=0.5) +
  geom_smooth(lwd=1.5, aes(group=Treatment, fill=Treatment)) +
  scale_x_continuous(breaks = unique(Data $ Timepoint)) +
  xlab(paste0('\n Timepoint (Days)')) +
  ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
print(p)
