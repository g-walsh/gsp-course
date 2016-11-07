multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

theme_gsp <- function() {
  theme(panel.background = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour="black", size=0.2),
        axis.text = element_text(colour="black"),
        axis.ticks = element_blank(),
        axis.ticks.length = unit(0, "cm"),
        plot.background = element_rect(fill="transparent",colour = NA))
}

library(ggplot2)

x <- seq(-4, 4, 0.01)
y <- dnorm(x)

p1 <- ggplot(data.frame(x,y),aes(x=x,y=y)) + geom_polygon(colour="#1B9E77",fill="#66C2A5") +
  theme_gsp() + ylab("probability") + xlab("value") + ggtitle("Normal distribution") +
  scale_y_continuous(limits=c(0,0.6),breaks=c(0,0.5))

x <- seq(-4, 4, 0.01)
y <- 0.5*dnorm(x) + 0.25*dnorm(x,2,0.6) + 0.25*dnorm(x,-1.5,0.7)

p2 <-  ggplot(data.frame(x,y),aes(x=x,y=y)) + geom_polygon(colour="#1B9E77",fill="#66C2A5") +
  theme_gsp() + ylab("probability") + xlab("value") + ggtitle("Arbitrary distribution") +
  scale_y_continuous(limits=c(0,0.6),breaks=c(0,0.5))


x <- seq(0, 2, 0.01)
y <- c(0,rep(0.5,length(x)-2),0)

p3 <-  ggplot(data.frame(x,y),aes(x=x,y=y)) + geom_polygon(colour="#1B9E77",fill="#66C2A5") +
 theme_gsp() + ylab("probability") + xlab("value") + ggtitle("Uniform distribution") +
  scale_y_continuous(limits=c(0,0.6),breaks=c(0,0.5))

multiplot(p1, p2, p3, cols=3)

