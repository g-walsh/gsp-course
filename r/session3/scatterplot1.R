library(ggplot2)

#Scatterplot
ggplot(dat2, aes(x=xs, y=ys)) + 
  geom_point(shape=1) + 
  labs(list(title = "Scatterplot", x = "x Points", y = "Y Points"))

# with regression curve
ggplot(dat2, aes(x=xs, y=ys)) + 
  geom_point(shape=1) + 
  geom_smooth(method=lm) + 
  labs(list(title = "Scatterplot", x = "x Points", y = "Y Points"))