
library(shiny)
library(reshape)
library(ggplot2)
library(knitr)
library(pander)
##-------------
library(traj)

shinyServer(function(input, output, session){    
        sim_fun <- function(A,d,g,t,sim,var,label, TV0){
          fun <- TV0*(A*exp(-d*t) + (1-A)*exp(g*t))
          Levels <- data.frame(label, t, replicate(sim, fun * rlnorm(length(t),0,var)))
          colnames(Levels)[3:(sim+2)] <- 1:sim
          return(Levels)
        }
    
    Simulated_data <- reactive({
      
      T    <- input $ T   ## length of follow up (e.g. days)
      t    <- 0:T         ## Timepoints
      sim  <- input $ sim ## Treatment arm size (number of animals)
      TV0  <- input $ TV0 ## starting Tumor Volume (mm3) level 
      var  <- input $ var ## multiplicative model log-normal error term variance 
      model_matrix <- input $ model_matrix
      
      Treat_nbr <- nrow(model_matrix) ## number of treatment arms
      Data <- array(1:(T+1), dim = c(T+1, sim+2, Treat_nbr))
      
      for(i in 1:Treat_nbr){
        A <- model_matrix[i,2]
        g <- model_matrix[i,3]
        d <- model_matrix[i,4]
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
      ## Wide format:
      Data <- Data3    
      Data_wide <- cast(Data, Study + Treatment + No ~ Timepoint, value.var='Level')
      for(i in 4:ncol(Data_wide)){
        if(as.numeric(colnames(Data_wide)[i]) < 10)
        {colnames(Data_wide)[i] <- paste0('Tp0',colnames(Data_wide)[i])}else{
          colnames(Data_wide)[i] <- paste0('Tp',colnames(Data_wide)[i])
        }
      }
      
      Data <- data.frame(Data_wide)
            
      ## Censoring
      
      if(input $ Censoring){
        medianSurv <- c(10, 13, 16) ## expected Treatment related median survival in days
        Treatments <- unique(Data $ Treatment)
        
        for(i in 1:length(Treatments)){
          rows <- which(Data $ Treatment == Treatments[i])
          randDays <- sample(size=length(rows), 
                             x=ceiling(rnorm(input $ sim, mean=medianSurv[i], sd=1.5)), replace=T)  
          colName <- ifelse(randDays < 10, paste0('Tp0', randDays), paste0('Tp', randDays))
          for(j in 1:length(rows)){
            randCol <- which(colnames(Data) == colName[j])
            Data[rows[j], c(randCol : ncol(Data))] = NA
          }
        }
      }      
    return(Data)
    })
        
        ## Save the Data (wide format):
        output$downloadData <- downloadHandler(
          filename = function() { paste('Simulated_Data_',Sys.time(), '_Ref_',1e5*round(runif(1),5),'.csv', sep='') },
          content = function(file) {
            write.csv(Simulated_data(), file, row.names=FALSE)
          }
        )
        
        ## Plotting setup:
        
        .theme <- theme(
          axis.line = element_line(colour = 'black', size = .75),
          ##panel.background = element_blank(),
          plot.background = element_blank(),
          axis.text=element_text(size=15),
          axis.title=element_text(size=17),
          legend.text=element_text(size=15), 
          legend.title=element_text(size=15), 
          legend.position='right',
          plot.title=element_text(size=20)
        )    
        
        yLab <- reactive({
          if(input $ Log10_transform){
            yLab = expression(paste('log10 Tumor volume ( ',mm^3,')'))}else{
              yLab = expression(paste('Tumor volume (',mm^3,')'))}
          return(yLab)
        })
        
## Plotting:        
        
    output $ Simulated_levels_plot <- renderPlot({
      Data <- Simulated_data()
      
      ##-----------------
      ## Transformations:
      ##-----------------
      Day.col <- which(is.element(colnames(Data), grep('Tp', colnames(Data), value=T)))[1]
      
      if(input $ Log10_transform){
        for(i in 1:nrow(Data)){
          for(j in (Day.col):ncol(Data)){
            if(!is.na(Data[i, j])){Data[i, j] <- log10(Data[i, j]+1)}
          }
        }
      }
      
      if(input $ LOCF){
        for(i in 1:nrow(Data)){
          for(j in (Day.col+1):ncol(Data)){
            if(is.na(Data[i, j])){Data[i, j] <- Data[i, j-1]}
          }
        }
      }
      
      Day.col <- which(is.element(colnames(Data), grep('Tp', colnames(Data), value=T)))[1]
      
      ## Transform to long-format      
      Data <- reshape(Data,
                      direction="long",
                      varying=list(names(Data)[Day.col : ncol(Data)]),
                      v.names="Response",
                      timevar="Timepoint",
                      times=names(Data)[Day.col : ncol(Data)])
      Data <- na.omit(Data)
      Data <- transform(Data, No=as.factor(No))
      Data <- transform(Data, Timepoint=as.numeric(sub('Tp','', Timepoint)))
      
      p <- ggplot(Data, aes(x=Timepoint, y=Response, group=No, col=Treatment)) + 
        geom_line() + 
        geom_point() +
        scale_x_continuous(breaks=c(0 : input $ T), limits=c(0, input $ T)) +
        ylab(yLab()) + 
        ggtitle('Simulated Responses\n') + .theme
      
      if(input $ LOESS == FALSE){
        print(p)
        }else{
          p <- p + geom_smooth(aes(group=Treatment, fill=Treatment), lwd=2)
        print(p)
      }
    })        
})## for function
