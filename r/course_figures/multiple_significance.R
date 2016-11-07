library(ggplot2)

x <- 0:100
df <- data.frame(x=x,y=1-0.95^x)
ggplot(df, aes(x=x,y=y)) +
  geom_line(colour="#1B9E77") +
  scale_y_continuous(labels = scales::percent) +
  ylab("prob. of significant result") +
  xlab("number of tests at 5% significance")

ggsave("multiple_significance.pdf", device=pdf, width=5.12, height=2.1, bg="transparent")
