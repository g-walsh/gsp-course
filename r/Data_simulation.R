##===========================================
## R script for Tumor Volume (TV) simulation
##===========================================

rm(list=ls())
library(reshape)

## Model simulating function:
sim_fun <- function(A,d,g,t,sim,var,label, TV0){
  fun <- TV0*(A*exp(-d*t) + (1-A)*exp(g*t))
  Levels <- data.frame(label, t, replicate(sim, fun * rlnorm(length(t),0,var)))
  colnames(Levels)[3:(sim+2)] <- 1:sim
  return(Levels)
}

## Input for simulation:
T    <- 20 ## length of follow up (e.g. days)
t    <- 0:T ## Timepoints
sim  <- 10 ## Treatment arm size (number of animals)
TV0  <- 10 ## starting Tumor Volume (mm3) level 
var  <- 0.3 ## multiplicative model log-normal error term variance 
##------------------------------------------------
## Model matrix:
xx <- matrix(c(c(1, 0, 0.15, 0),
               c(2, 0.5, 0.15, 0),
               c(3, 0.8, 0.1, 0.35)
              ), ncol=4, byrow=TRUE)
model_matrix <- data.frame('Treatment'=xx[, 1],'A'=xx[, 2],'g'=xx[, 3],'d'=xx[, 4])
## model_matrix content:
## 'Treatment': Treatment number
## 'A': cell death rate
## 'g': growth rate
## 'd': inhibition rate
##------------------------------------------------

Treat_nbr <- nrow(model_matrix) ## number of treatment arms
Data <- array(1:(T+1), dim = c(T+1, sim+2, Treat_nbr))

for(i in 1:Treat_nbr){
  A <- model_matrix[i,2]
  g <- model_matrix[i,3]
  d <- model_matrix[i,4]
  var <- var
  Data[1:(T+1), 1:(sim + 2), i] <- as.matrix(sim_fun(A, d, g, t, sim, var, label=paste0('Tr', i), TV0))
}
colnames(Data) <- c('label','t', 1:sim)

## auxiliary set
Data_aux <- data.frame(Data[,,1])
aux <- melt(Data_aux, id.vars=c('label', 't'), measure.vars=colnames(Data_aux)[3:ncol(Data_aux)])

Data1 <- array(1:nrow(aux), dim=c(nrow(aux), ncol(aux), Treat_nbr))
for(i in 1:Treat_nbr){
  Data_aux <- data.frame(Data[,,i])
  Data1[1:nrow(aux), 1:ncol(aux) , i] <- as.matrix(melt(Data_aux, id.vars=c('label', 't'), measure.vars=colnames(Data_aux)[3:ncol(Data_aux)]))
}    

Data2 <- data.frame(Levels = as.numeric(Data1[,4,]))    

Treatments <- paste0('Tr',model_matrix[,1])
id <- 1:(sim * length(Treatments))
Timepoint <- rep(t, length(Treatments)*sim)
Treatment <- rep(Treatments, rep(sim * length(t),length(Treatments)))
No <- rep(id, rep(length(t), sim*length(Treatments)))

Data3 <- data.frame(Study='St1', Treatment, No, Timepoint, Level=Data2 $ Levels)

##----------------------
## saves data in a wide format:
Data <- Data3    
Data_wide <- cast(Data, Study + Treatment + No ~ Timepoint, value.var='Level')
for(i in 4:ncol(Data_wide)){
  if(as.numeric(colnames(Data_wide)[i]) < 10)
  {colnames(Data_wide)[i] <- paste0('Tp0',colnames(Data_wide)[i])}else{
    colnames(Data_wide)[i] <- paste0('Tp',colnames(Data_wide)[i])
  }
}

## (Optinal) With censoring:
# medianSurv <- c(10, 13, 16) ## expected Treatment related median survival in days
# Treatments <- unique(Data_wide $ Treatment)
# 
# for(i in 1:length(Treatments)){
#   rows <- which(Data_wide $ Treatment == Treatments[i])
#   randDays <- sample(size=length(rows), 
#                      x=ceiling(rnorm(10, mean=medianSurv[i], sd=2)), replace=T)  
#   colName <- ifelse(randDays < 10, paste0('Tp0', randDays), paste0('Tp', randDays))
#   for(j in 1:length(rows)){
#     randCol <- which(colnames(Data_wide) == colName[j])
#     Data_wide[rows[j], c(randCol : ncol(Data_wide))] = NA
#   }
# }

Data <- data.frame(Data_wide)

## Saves in wide format (.csv)
write.csv(Data, file='Simulated_data.csv', row.names=FALSE)


## Transforms to long format and saves as .RData
NA.cols <- which(sapply(Data, function(x){all(is.na(x))}))
if(length(NA.cols) > 0){Data <- Data[,-NA.cols]}
Day.col <- which(is.element(colnames(Data), grep('Tp', colnames(Data), value=T)))[1]

## (Optional) For log10-transform:
for(i in 1:nrow(Data)){
  for(j in (Day.col):ncol(Data)){
    if(!is.na(Data[i, j])){Data[i, j] <- log10(Data[i, j]+1)}
  }
}

## (Optional) For Last-Observation-Carried-Forward (LOCF) imputation:
for(i in 1:nrow(Data)){
  for(j in (Day.col+1):ncol(Data)){
    if(is.na(Data[i, j])){Data[i, j] <- Data[i, j-1]}
  }
}

Data <- reshape(Data,
                direction="long",
                varying=list(names(Data)[Day.col : ncol(Data)]),
                v.names="Response",
                timevar="Timepoint",
                times=names(Data)[Day.col : ncol(Data)])
Data <- na.omit(Data)
Data <- transform(Data, No=as.factor(No))
Data <- transform(Data, Timepoint=as.numeric(sub('Tp','', Timepoint)))

library(ggplot2)
ggplot(Data, aes(x=Timepoint, y=Response, group=No, col=Treatment)) + geom_point() + geom_line()

save(Data, file='Simulated_data.RData')
