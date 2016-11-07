##############################################################
# Plot the simulated data as histogram to show non-normality #
##############################################################

rm(list=ls())

# Import data and define included days for the experiemnt.

Data <-  read.csv('Simulated_data.csv', header=TRUE)
Start_Day <- 6 ## first day number of the selected period
End_Day <- 20 ## last day number of the selected period

# Define which columns of the data set represent those containing tumour volume information

Day.col <- which(is.element(colnames(Data), grep('Tp', colnames(Data), value=T)))[1]
xx <- as.numeric(sub('Tp','', colnames(Data)[Day.col:ncol(Data)]))
col.Day.start <- which(xx == Start_Day) + Day.col - 1
col.Day.end   <- which(xx == End_Day) + Day.col - 1

# Make the data long and plot histograms for the data and the log transformed data

tumourdata <- Data[col.Day.start:col.Day.end]
tumour_long <- melt(tumourdata)
ggplot(data = tumour_long, aes(x=value)) +
  geom_histogram(binwidth=25, colour="black", fill="white")

tumour_long_log <- tumour_long
tumour_long_log$value <- log10(tumour_long_log$value)
ggplot(data = tumour_long_log, aes(x=value)) +
  geom_histogram(binwidth=0.25, colour="black", fill="white")

# Can do this with density plot instead e.g.
#ggplot(data = tumour_long, aes(x=value)) +
#  geom_histogram(aes(y=..density..),binwidth=0.25, colour="black", fill="white") +
#  geom_density()