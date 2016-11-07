
library(shiny)
library(pwr)
library(lmerTest)
library(reshape)
library(ggplot2)
library(knitr)
library(pander)

shinyServer(function(input, output, session){
    
  d.powerPlot <- eventReactive(input $ run_d,{
    input $ ES == 'Cohen`s d'
  })
  
  GIR.powerPlot <- eventReactive(input $ run_GIR,{
    input $ ES == 'Growth Inhibition Rate'  
  })
  
  ## Plotting theme
  .theme <- theme(
    axis.line = element_line(colour = 'black', size = .75),
    #panel.background = element_blank(),
    plot.background = element_blank(),
    axis.text=element_text(size=15),
    axis.title=element_text(size=17),
    legend.text=element_text(size=15), 
    legend.title=element_text(size=15), 
    plot.title=element_text(size=20)
  )
  
  
  output $ download_report_ES_d <- downloadHandler(filename = 'Study_design_ES_d.pdf',
                                              content = function(file){
                                                
                                                rnw <- normalizePath('Study_design_report_ES_d.Rnw')
                                                refer <- normalizePath('refer.bib')
                                                
                                                owd <- setwd(tempdir())
                                                on.exit(setwd(owd))
                                                file.copy(refer, 'refer.bib')
                                                
                                                out = knit2pdf(rnw, clean=TRUE)
                                                file.rename(out, file)
                                              },
                                              contentType = "application/pdf"
  )
  
    
    ## Cohen`s d
output $ powerCurve_ES_d  <- renderPlot({
  d.powerPlot()
    sample.n  <- c(3:15) ## possible sample size scenarios
    Perm.power <- data.frame()
    ES.d.point  <- input $ ES_d_point
    ES.seq <- seq(input $ ES_d_min, input $ ES_d_max, by=0.05)
    ES.seq.plot <- round(seq(input $ ES_d_min, input $ ES_d_max, length=10),1)
    alpha <- as.numeric(input $ alpha)
    
    for(i in 1:length(ES.seq)){
      for(j in 1:length(sample.n)){
        n <- sample.n[j]
        Perm.power[j,1] <- n
        Perm.power[j,i+1] <- pwr.t2n.test(n1=n,
                                          n2=n,
                                          d = ES.seq[i],
                                          sig.level = alpha,
                                          power = NULL) $ power
      } ## for j
      colnames(Perm.power)[1] <- 'Group_size'
      colnames(Perm.power)[i+1] <- paste0(ES.seq[i])
    } ## for i
  
    Perm.power1 <- melt(Perm.power, id.vars=1)
    Perm.power1 <- transform(Perm.power1, Group_size=as.factor(Group_size))
    Perm.power1 <- transform(Perm.power1, variable=as.numeric(levels(variable))[variable])
  
    p <- ggplot(Perm.power1, aes(x=variable, y=value, group=Group_size, col=Group_size)) + 
      geom_point(size=2.5) + geom_line(lwd=.7) + 
      xlab('\n(Expected) Effect size: d') + ylab('Power\n') + 
      scale_y_continuous(breaks=seq(0,1,.1), limits=c(0,1)) + 
      geom_hline(yintercept = 0.8, col='red', lty=2, lwd=.7) + 
      geom_vline(xintercept = ES.d.point, col='grey', lty=1, lwd=.6) + 
      scale_x_continuous(breaks=ES.seq.plot) + 
    ggtitle(paste('Power for effect size d and significance', alpha)) + .theme
  
    print(p)
    })
        
    ## Growth Inhibition Rate

## Functions to simulate LME:
simulate.LME.S <- function(n,beta,theta,sigma,
                           Timepoints,
                           Treatments,
                           Model.LME,
                           S){
  Timepoint <- rep(Timepoints, n*length(Treatments))
  Treatment <- as.factor(rep(Treatments, rep(n*length(Timepoints), length(Treatments))))
  No <- as.factor(rep(1:(length(Treatments)*n), rep(length(Timepoints), n*length(Treatments))))
  data.sim <- data.frame(No, Treatment, Timepoint)
  Response <- simulate(formula(Model.LME)[-2],
                       newdata=data.sim, nsim=S,
                       newparams = list(beta = beta, theta=theta, sigma=sigma),
                       family=gaussian)[,1:S]
  list(data.sim=data.sim, Response=Response)
}

power.LME <- function(simulated.LME,
                      param,
                      alpha,
                      Model.LME,
                      sim){
  data.sim <- simulated.LME $ data.sim
  Response <- simulated.LME $ Response
  data.sim $ y <- Response[,sim]
  library(lmerTest)
  Fit <- lmer(update(formula(Model.LME), y ~ .), data=data.sim)
  ##-----------------------------------
  Est <- fixef(Fit)[param]
  Ste <- sqrt(diag(vcov(Fit)))[param]
  prod(Est + c(-1,1) * qnorm(1-alpha/2) * Ste) > 0 ## product of confidence interval
}

    output $ powerCurve_ES_GIR <- renderPlot({
      GIR.powerPlot()
    ##---------------------
    load('Model_LME.RData')    
    beta <- fixef(Model.LME)
    theta <- getME(Model.LME, 'theta')
    sigma <- getME(Model.LME, 'sigma')
    Timepoints <- 1:input $ Timepoints
    Treatments <- c('Baseline','Treat_A')
    ##---------------------
      sample.n  <- c(input $ n) ## possible sample size scenarios
      ES_GIR_point <- input $ ES_GIR_point
      LME.power <- data.frame()
    ##GIR <- seq(.05, .4, .05)
    ##alpha=0.05
    GIR <- seq(input $ ES_GIR_min, input $ ES_GIR_max, by=5)/100 ## reduction rate from the baseline
      alpha <- as.numeric(input $ alpha)
      ## Tumor volume reduction in treatment line as a percentage of beta[2], the rate which reflects the Contriol group dynamics.
   withProgress(message = 'Progress:', min=1, max=length(GIR), {              
      for(i in 1:length(GIR)){
        print(i)
        incProgress(1/length(GIR), detail = paste0("GIR = ", 100*GIR[i], '% (max=',100*max(GIR),'%)'))
        beta1 <- beta
        beta1[4] <- -beta[2]*(GIR[i])

        for(j in 1:length(sample.n)){
          n <- sample.n[j]
           S <- 1e3
          simulated.LME <- simulate.LME.S(n,beta=beta1, theta=theta, sigma,
                                          Timepoints,
                                          Treatments,
                                          Model.LME,
                                          S)
          ##--------------------------------------------------

          outcome <- as.numeric()  
          for(s in 1:S){
            outcome[s] <- power.LME(simulated.LME,
                          param=4,
                          alpha,
                          Model.LME,
                          sim=s)}
          ##--------------------------------------------------
          LME.power[j,1] <- sample.n[j]
          LME.power[j,i+1] <- mean(outcome)
          
          ##-----------------------------
          cat(paste0('Growth rate reduction: ', 100*GIR[i], '%', ', ni=', sample.n[j], ', Power=', mean(outcome)), '\n');flush.console()
        } ## for j
        colnames(LME.power)[1] <- 'Group_size'
        colnames(LME.power)[i+1] <- paste0(100*GIR[i], '%')
      } ## for i
    }) ## for progress
      
      LME.power1 <- melt(LME.power, id.vars=1)
      LME.power1 <- transform(LME.power1, Group_size=as.factor(Group_size))
      
      GIR.point <- which(GIR==ES_GIR_point)
    p <- ggplot(LME.power1, aes(x=variable, y=value, group=Group_size, col=Group_size)) + 
      geom_point(size=3.5) + geom_line(lwd=1) + 
      xlab('\n(Expected) Percentage reduction from the baseline growth rate') + ylab('Power\n') + 
      scale_y_continuous(breaks=seq(0,1,.1), limits=c(0,1)) + 
      geom_hline(yintercept=0.8, col='red', lty=2, lwd=.6) +
      geom_vline(xintercept=GIR.point, col='grey', lty=2, lwd=.6) + 
      ggtitle(paste('Power for effect size GIR and significance', alpha)) + .theme
      print(p)
    })
})## for function
