library(ggplot2)
library(Cairo)

x <- 0:7
df <- data.frame(x=x,y=dbinom(x,7,0.5))
ggplot(df, aes(x=x,y=y)) +
  geom_bar(data=df[0:5,], fill="#1B9E77", stat="identity") +
  geom_bar(data=df[5:8,], fill="#66C2A5", stat="identity") +
  ylab("probability") + scale_y_continuous(lim=c(0,0.3), expand=c(0, 0.01)) +
  scale_x_continuous(breaks=0:7, lim=c(-0.5,7.5)) +
  theme(panel.background = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour="black", size=0.2),
        axis.text = element_text(colour="black"),
        axis.ticks = element_blank(),
        axis.ticks.length = unit(0, "cm"),
        plot.background = element_rect(fill="transparent",colour = NA))

ggsave("example_corneal.pdf", device=pdf, width=3, height=2, bg="transparent")
