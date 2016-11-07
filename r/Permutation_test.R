##===========================
## Permutation-based test
##===========================

rm(list=ls())

library(statmod) ## packages implementing permutation test

## Requires data in wide format
Data <-  read.csv('Simulated_data.csv', header=TRUE)
Treatments <- c('Tr1', 'Tr2', 'Tr3') ## choose treatments to compare
Start_Day <- 6 ## first day number of the selected period
End_Day <- 20 ## last day number of the selected period
##-----------------------------------------------------------------------------------
Day.col <- which(is.element(colnames(Data), grep('Tp', colnames(Data), value=T)))[1]
Data <- Data[which(is.element(Data $ Treatment, Treatments)),]
xx <- as.numeric(sub('Tp','', colnames(Data)[Day.col:ncol(Data)]))
col.Day.start <- which(xx == Start_Day) + Day.col - 1
col.Day.end   <- which(xx == End_Day) + Day.col - 1
##-----------------------------------------------------------------------------------

set.seed(123)
output <- compareGrowthCurves(group = Data $ Treatment,
                                      y = Data[, col.Day.start : col.Day.end],
                                      levels = unique(Data $ Treatment),
                                      nsim = 1e3,
                                      fun = meanT,
                                      times = NULL,
                                      verbose = FALSE,
                                      adjust = "holm")

colnames(output) <- c('Group 1', 'Group 2', 't-value', 'p-value', 'p-value (Holm`s corr.)')
