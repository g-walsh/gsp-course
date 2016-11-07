
library(shiny)
library(statmod)
library(lmerTest)
library(reshape)
library(ggplot2)
library(knitr)
library(pander)
library(lsmeans)

library(xtable)


shinyServer(function(input, output, session){
  ## Data reactives:
    uploaded_Data <- reactive({
        inFile <- input $ data
        if(is.null(inFile)){return(NULL)}
        data <- read.csv(file = inFile $ datapath, header=TRUE)
        return(data)
    })

    output $ download_Report_Perm <-
      downloadHandler(filename = paste('Report_Perm_',input $ study,'.pdf', sep=''),
                      content = function(file){
                        rnw <- normalizePath('Report_Perm.Rnw')
                        refer <- normalizePath('refer.bib')
                        
                        owd <- setwd(tempdir())
                        on.exit(setwd(owd))
                        file.copy(refer, 'refer.bib')
                        
                        out = knit2pdf(rnw, clean=TRUE)
                        file.rename(out, file)
                      },
                      contentType = "application/pdf"
      )
    
    output $ download_Report_LME <-
      downloadHandler(filename = paste('Report_LME_',input $ study,'.pdf', sep=''),
                      content = function(file){
                        rnw <- normalizePath('Report_LME.Rnw')
                        refer <- normalizePath('refer.bib')
                        
                        owd <- setwd(tempdir())
                        on.exit(setwd(owd))
                        file.copy(refer, 'refer.bib')
                        
                        out = knit2pdf(rnw, clean=TRUE)
                        file.rename(out, file)
                      },
                      contentType = "application/pdf"
      )
    
    output $ download_Report_LME_with_trend <-
      downloadHandler(filename = paste('Report_LME_with_trend_',input $ study,'.pdf', sep=''),
                      content = function(file){
                        rnw <- normalizePath('Report_LME_with_trend.Rnw')
                        refer <- normalizePath('refer.bib')
                        
                        owd <- setwd(tempdir())
                        on.exit(setwd(owd))
                        file.copy(refer, 'refer.bib')
                        
                        out = knit2pdf(rnw, clean=TRUE)
                        file.rename(out, file)
                      },
                      contentType = "application/pdf"
      )
    
    ## Raw data presentation section:
    output $ raw_data <- renderTable({
      uploaded_Data()
    })## for table
    
    get_Treatment_names <- reactive({
      Study_codes <- ''
      if(!is.null(input$data)){
        data <- read.csv(file = input$data$datapath, header=TRUE)
        codes <- as.character(unique(data$Treatment))
        names(codes) <- codes
        Study_codes <- codes
      }
      return(Study_codes)
    })
    
    get_Day_numbers <- reactive({
      days <- ''
      if(!is.null(input$data)){
        Data <- Data.raw()
        days <- as.character(unique(Data $ Timepoint))
      }
      return(days)
    })
    
    
    get_Study_name <- reactive({
      Study_name <- ''
      if(!is.null(input$data)){
        data <- read.csv(file = input $ data $ datapath, header=TRUE)
        Study_name <- as.character(unique(data$Study))
      }
      return(Study_name)
    })
    
    observe({
      updateCheckboxGroupInput(session, 'Tr', label='Select treatment lines', choices=get_Treatment_names())
      updateSelectInput(session,"Day_start",label = 'Change first day', choices = get_Day_numbers(), selected=min(as.numeric(get_Day_numbers())))
      updateSelectInput(session,"Day_end", label = 'Change last day', choices = get_Day_numbers(), selected=max(as.numeric(get_Day_numbers())))
      ##-----------------------------------------------------
      updateCheckboxGroupInput(session, 'Tr_Perm', label='Select treatment lines', choices=get_Treatment_names())
      updateSelectInput(session,"Day_start_Perm",label = 'Select first day', choices = get_Day_numbers(), selected=min(as.numeric(get_Day_numbers())))
      updateSelectInput(session,"Day_end_Perm",label = 'Select last day', choices = get_Day_numbers(), selected=max(as.numeric(get_Day_numbers())))
      ##-----------------------------------------------------
      updateCheckboxGroupInput(session, 'Tr_LME_baseline', label='Select baseline treatment line', choices=get_Treatment_names())
      updateCheckboxGroupInput(session, 'Tr_LME_investigated', label='Select investigated treatment line(s)', choices=get_Treatment_names())
      updateSelectInput(session,"Day_start_LME",label = 'Select first day (baseline)', choices = get_Day_numbers(), selected=min(as.numeric(get_Day_numbers())))
      updateSelectInput(session,"Day_end_LME",label = 'Select last day', choices = get_Day_numbers(), selected=max(as.numeric(get_Day_numbers())))
      ##-----------------------------------------------------
      updateCheckboxGroupInput(session, 'Tr_LME_trend_baseline', label='Select baseline treatment line', choices=get_Treatment_names())
      updateCheckboxGroupInput(session, 'Tr_LME_trend_investigated', label='Select investigated treatment line(s)', choices=get_Treatment_names())
      updateSelectInput(session,"Day_start_LME_trend",label = 'Select first day', choices = get_Day_numbers(), selected=min(as.numeric(get_Day_numbers())))
      updateSelectInput(session,"Day_end_LME_trend",label = 'Select last day', choices = get_Day_numbers(), selected=max(as.numeric(get_Day_numbers())))
      ##-----------------------------------------------------
      updateTextInput(session,'study', label='Study name:', value=get_Study_name())
    })
    
    ## Data:
    Data.raw <- reactive({
      if(is.null(input $ data)){return(NULL)}else{
        data <- uploaded_Data()
        ##-----------------------
        ## find columns with all NA and remove them:
        NA.cols <- which(sapply(data, function(x){all(is.na(x))}))
        if(length(NA.cols>0)){data <- data[,-NA.cols]}
        Day.col <- which(is.element(colnames(data), grep('Tp', colnames(data), value=T)))[1]
        Data <- reshape(data,
                        direction="long",
                        varying=list(names(data)[Day.col : ncol(data)]),
                        v.names="Response",
                        timevar="Timepoint",
                        times=names(data)[Day.col : ncol(data)])
        Data <- na.omit(Data)
        Data <- transform(Data, No=as.factor(No))
        Data <- transform(Data, Timepoint=as.numeric(sub('Tp','', Timepoint)))
        return(Data)
      }
    })
    
    ## Data with Timepoint as factor:
    Data <- reactive({
      if(is.null(input $ data)){return(NULL)}else{
        data <- uploaded_Data()
        ##-----------------------
        NA.cols <- which(sapply(data, function(x){all(is.na(x))}))
        if(length(NA.cols > 0)){data <- data[,-NA.cols]}
        Day.col <- which(is.element(colnames(data), grep('Tp', colnames(data), value=T)))[1]

        ## log10-transform:
        if(is.element('log10-transform', input $ Trans)){
          for(i in 1:nrow(data)){
            for(j in (Day.col):ncol(data)){
              if(!is.na(data[i, j])){data[i, j] <- log10(data[i, j]+1)}
            }
          }
        }

        ## Imputation:
        if(is.element('LOCF', input $ Trans)){
          for(i in 1:nrow(data)){
            for(j in (Day.col+1):ncol(data)){
              if(is.na(data[i, j])){data[i, j] <- data[i, j-1]}
            }
          }
        }
        
        Data <- reshape(data,
                        direction="long",
                        varying=list(names(data)[Day.col : ncol(data)]),
                        v.names="Response",
                        timevar="Timepoint",
                        times=names(data)[Day.col : ncol(data)])
        Data <- na.omit(Data)
        Data <- transform(Data, No=as.factor(No))
        Data <- transform(Data, Timepoint=as.numeric(sub('Tp','', Timepoint)))
        return(Data)
      }
    })
    
    
    ## Plotting theme
    .theme <- theme(
      axis.line = element_line(colour = 'black', size = .75),
      plot.background = element_blank(),
      axis.text=element_text(size=15),
      axis.title=element_text(size=17),
      legend.text=element_text(size=15), 
      legend.title=element_text(size=15), 
      plot.title=element_text(size=20)
    )
    
    ## Appropriate to applied transforms ylab for ggplot
    yLab <- reactive({
      if(is.element('log10-transform',input $ Trans)){
        yLab = expression(paste('log10 Tumor volume ( ',mm^3,')'))}else{
          yLab = expression(paste('Tumor volume (',mm^3,')'))}
      return(yLab)
    })
    
    
    output $ Plot_raw_data <- renderPlot({
      if(is.null(input $ data)){return(NULL)}else{
        Data <- Data.raw()
        p <- ggplot(Data, aes(x=Timepoint, y=Response, group=No, col=Treatment)) +
          geom_point(size=1.9) + geom_line(lty=1, lwd=0.5) +
          scale_x_continuous(breaks = unique(Data $ Timepoint)) +
          ylab(expression(paste('Tumor volume ( ',mm^3,')'))) +
          xlab(paste('\n', input $ time_unit)) +
          ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
        print(p)
      }
    })
    
    output $ Spaghetti_plot <- renderPlot({
      if(is.null(input $ data)){return(NULL)}else{
        Data <- Data()
        from <- min(Data $ Response)
        to <- max(Data $ Response)
        ##------------------------------------------
        Data <- droplevels(subset(Data, is.element(Treatment, input $ Tr)))
        Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start) & Timepoint <= as.numeric(input $ Day_end)))
        
        p <- ggplot(Data, aes(x=Timepoint, y=Response, group=No, col=Treatment)) +
          geom_point(size=1.9) + geom_line(lty=1, lwd=0.5) +
          scale_x_continuous(breaks = unique(Data $ Timepoint)) +
          scale_y_continuous(limits = c(from, to)) +
          ylab(yLab()) +
          xlab(paste0('\n Timepoint (', input $ time_unit, ')')) +
          ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
        print(p)
      }
    })
    
    
    summary_mean_SE_CI <- function (data = NULL, measurevar, groupvars = NULL, na.rm = FALSE, 
                           conf.interval = 0.95, .drop = TRUE) 
    {
      require(plyr)
      length2 <- function(x, na.rm = FALSE) {
        if (na.rm) 
          sum(!is.na(x))
        else length(x)
      }
      datac <- plyr::ddply(data, groupvars, .drop = .drop, .fun = function(xx, col, na.rm) {
        c(N = length2(xx[, col], na.rm = na.rm), mean = mean(xx[,col], na.rm = na.rm), sd = sd(xx[, col], na.rm = na.rm))
      }, measurevar, na.rm)
      datac <- rename(datac, c(mean = measurevar))
      datac$se <- datac$sd/sqrt(datac$N)
      ciMult <- qt(conf.interval/2 + 0.5, datac$N - 1)
      datac$ci <- datac$se * ciMult
      return(datac)
    }
    
    
    summary_median <- function (data = NULL, measurevar, groupvars = NULL, na.rm = FALSE, 
                                    conf.interval = 0.95, .drop = TRUE) 
    {
      require(plyr)
      length2 <- function(x, na.rm = FALSE) {
        if (na.rm) 
          sum(!is.na(x))
        else length(x)
      }
      datac <- plyr::ddply(data, groupvars, .drop = .drop, .fun = function(xx, col, na.rm) {
        c(N = length2(xx[, col], na.rm = na.rm), median = median(xx[,col], na.rm = na.rm))}, measurevar, na.rm)
      datac <- rename(datac, c(median = measurevar))
      return(datac)
    }
    
    output $ MeanSE_plot <- renderPlot({
      Data <- Data()
      from <- min(Data $ Response)
      to <- max(Data $ Response)
      ##-----------------------------------------
      Data <- droplevels(subset(Data, is.element(Treatment, input $ Tr)))
      Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start) & Timepoint <= as.numeric(input $ Day_end)))
      ##-----------------------------------------
      dfc <- summary_mean_SE_CI(Data, measurevar="Response", groupvars=c("Treatment","Timepoint"), na.rm=T)
      pd <- position_dodge(.4) ## jittering
      p <- ggplot(dfc, aes(x=Timepoint, y=Response, colour=Treatment, group=Treatment)) +
        geom_errorbar(aes(ymin=Response-se, ymax=Response+se), width=.8, lwd=1.1, position=pd) +
        geom_line(position=pd, lwd=1.1) +
        geom_point(position=pd, size=3) +
        scale_x_continuous(breaks = unique(Data $ Timepoint)) +
        ## scale_y_continuous(limits = c(from, to)) +
        ylab(yLab()) +
        xlab(paste0('\n Timepoint (', input $ time_unit, ')')) +
        ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
      print(p)
    })
    
    
    output $ Median_plot <- renderPlot({
      Data <- Data()
      from <- min(Data $ Response)
      to <- max(Data $ Response)
      ##-----------------------------------------
      Data <- droplevels(subset(Data, is.element(Treatment, input $ Tr)))
      Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start) & Timepoint <= as.numeric(input $ Day_end)))
      ##-----------------------------------------
      dfc <- summary_median(Data, measurevar="Response", groupvars=c("Treatment","Timepoint"), na.rm=T)
      pd <- position_dodge(.4) ## jittering
      p <- ggplot(dfc, aes(x=Timepoint, y=Response, colour=Treatment, group=Treatment)) +
        geom_line(position=pd, lwd=1.1) +
        geom_point(position=pd, size=3) +
        scale_x_continuous(breaks = unique(Data $ Timepoint)) +
        ## scale_y_continuous(limits = c(from, to)) +
        ylab(yLab()) +
        xlab(paste0('\n Timepoint (', input $ time_unit, ')')) +
        ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
      
      print(p)
    })
    
    
    output $ LOESS_plot <- renderPlot({
      if(is.null(input $ data)){return(NULL)}else{
        Data <- Data()
        from <- min(Data $ Response)
        to <- max(Data $ Response)
        ##------------------------------------------
        Data <- droplevels(subset(Data, is.element(Treatment, input $ Tr)))
        Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start) & Timepoint <= as.numeric(input $ Day_end)))
        ## Data <- droplevels(subset(Data, Timepoint >= 6 & Timepoint <= 27))
        
        
        p <- ggplot(Data, aes(x=Timepoint, y=Response, group=No, col=Treatment)) +
          geom_point(size=1.9) + geom_line(lty=1, lwd=0.5) +
          geom_smooth(lwd=1.5, aes(group=Treatment, fill=Treatment)) +
          scale_x_continuous(breaks = unique(Data $ Timepoint)) +
          ## scale_y_continuous(limits = c(from, to)) +
          ylab(yLab()) +
          xlab(paste0('\n Timepoint (', input $ time_unit, ')')) +
          ggtitle(paste('Study:', unique(Data $ Study),'\n', sep=' ')) + .theme
        print(p)
      }
    })
        
    
    Data.wide <- reactive({
      data <-  uploaded_Data()
      ##-------------------------------------------------------
      NA.cols <- which(sapply(data, function(x){all(is.na(x))}))
      if(length(NA.cols > 0)){data <- data[,-NA.cols]}
      Day.col <- which(is.element(colnames(data), grep('Tp', colnames(data), value=T)))[1]

      if(is.element('log10-transform', input $ Trans)){
        ## log10-transform:
        for(i in 1:nrow(data)){
          for(j in Day.col:ncol(data)){
            if(!is.na(data[i, j])){data[i, j] <- log10(data[i, j]+1)}
          }
        }
      }
      
      if(is.element('LOCF', input $ Trans)){
        ## Imputation:
        for(i in 1:nrow(data)){
          for(j in (Day.col+1):ncol(data)){
            if(is.na(data[i, j])){data[i, j] <- data[i, j-1]}
          }
        }
      }
      
      return(data)
      
    })
    
    
    ## Function for permutation-based test Effect size:
    perm.ES <- function(group, y){
      group <- as.vector(group)
      g <- unique(group)
      y1 <- y[group == g[1], , drop = FALSE]
      y2 <- y[group == g[2], , drop = FALSE]
      if (is.null(dim(y1)) || is.null(dim(y2)))
        return(NA)
      y1 <- as.matrix(y1)
      y2 <- as.matrix(y2)
      if (ncol(y1) != ncol(y2))
        stop("Number of time points must match")
      m1 <- colMeans(y1, na.rm = TRUE)
      m2 <- colMeans(y2, na.rm = TRUE)
      v1 <- apply(y1, 2, var, na.rm = TRUE)
      v2 <- apply(y2, 2, var, na.rm = TRUE)
      n1 <- apply(!is.na(y1), 2, sum)
      n2 <- apply(!is.na(y2), 2, sum)
      s <- ((n1 - 1) * v1 + (n2 - 1) * v2)/(n1 + n2 - 2)
      t_stat <- abs(m1 - m2)/sqrt(s)
      ES <- 2*t_stat/sqrt(n1+n2-2) ## effect size given the t-statistics
      return(mean(ES, na.rm=TRUE))
    }
    
    compareGrowthCurves_with_ES <- function (group, y, levels = NULL, nsim = 100, fun = meanT, times = NULL,
                                             verbose = TRUE, adjust = "holm")
    {
      group <- as.character(group)
      if (is.null(levels)) {
        tab <- table(group)
        tab <- tab[tab >= 2]
        lev <- names(tab)
      }
      else lev <- as.character(levels)
      nlev <- length(lev)
      if (nlev < 2)
        stop("Less than 2 groups to compare")
      if (is.null(dim(y)))
        stop("y must be matrix-like")
      y <- as.matrix(y)
      if (!is.null(times))
        y <- y[, times, drop = FALSE]
      g1 <- g2 <- rep("", nlev * (nlev - 1)/2)
      stat <- pvalue <- Effect.size <- rep(0, nlev * (nlev - 1)/2)
      pair <- 0
      for (i in 1:(nlev - 1)) {
        for (j in (i + 1):nlev) {
          if (verbose)
            cat(lev[i], lev[j])
          pair <- pair + 1
          sel <- group %in% c(lev[i], lev[j])
          out <- compareTwoGrowthCurves(group[sel], y[sel,, drop = FALSE], nsim = nsim, fun = fun)
          ES <- perm.ES(group[sel], y[sel,, drop = FALSE])
          if (verbose)
            cat(" ", round(out$stat, 2), "\n")
          g1[pair] <- lev[i]
          g2[pair] <- lev[j]
          stat[pair] <- out$stat
          pvalue[pair] <- out$p.value
          Effect.size[pair] <- abs(ES)
        }
      }
      tab <- data.frame(Group1 = g1, Group2 = g2, Stat = stat,
                        P.Value = pvalue)
      tab$adj.P.Value <- p.adjust(pvalue, method = adjust)
      tab$Effect.size <- Effect.size
      tab
    }
    
    output $ Permutation_test <- renderTable({
      if(input $ Test == 'Permutation-based test'){
        if(is.null(input $ data)){return(NULL)}else{
          data <-  Data.wide()
          ##-----------------------------------------------------------------------------------
          Day.col <- which(is.element(colnames(data), grep('Tp', colnames(data), value=T)))[1]
          data <- data[which(is.element(data $ Treatment, c(input $ Tr_Perm))),]
          xx <- as.numeric(sub('Tp','', colnames(data)[Day.col:ncol(data)]))
          col.Day.start <- which(xx == input $ Day_start_Perm) + Day.col - 1
          col.Day.end   <- which(xx == input $ Day_end_Perm) + Day.col - 1
          ##-----------------------------------------------------------------------------------
          set.seed(123)
          output <- compareGrowthCurves_with_ES(group = data $ Treatment,
                                                y = data[, col.Day.start : col.Day.end],
                                                levels = unique(data $ Treatment),
                                                nsim = 1e3,
                                                fun = meanT,
                                                times = NULL,
                                                verbose = FALSE,
                                                adjust = "holm")
          
          colnames(output) <- c('Group 1', 'Group 2', 't-value', 'p-value', 'p-value (Holm`s)','Cohen`s d')
          return(output)
        }
      }
    }, digits=3)
    
    
    ##=========================================================================
    ## Model with trend:
    Model_LME_trend <- reactive({
      Data <- Data()
      ##----------------------------------------------------
      Data <- droplevels(subset(Data, is.element(Treatment, c(input $ Tr_LME_trend_baseline, input $ Tr_LME_trend_investigated))))
      Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start_LME_trend) & Timepoint <= as.numeric(input $ Day_end_LME_trend)))
      Data <- within(Data, Treatment <- relevel(Treatment, ref = input $ Tr_LME_trend_baseline))
      Data <- transform(Data, Timepoint=as.factor(Timepoint))
      Data <- transform(Data, Timepoint=as.numeric(Timepoint))
      ##-------------------------------------------------------------------------
      Model_LME <- lmer(Response ~ 1 + Timepoint * Treatment + (1|No), data=Data)
      return(Model_LME)
    })
    
    ## Model summary (fixed-effects only):
    output $ Model_LME_trend_summary_FE <- renderTable({
      if(is.null(input $ data)){return(NULL)}else{
        Model_LME <- Model_LME_trend()
        return(summary(Model_LME) $ coefficients)
      }
    }, digits=3)

    ## Plot LME with trend:
    output $ LME_trend_plot <- renderPlot({
      if(is.null(input $ data)){return(NULL)}else{
        Data <- Data()
        ##----------------------------------------------------
        Data <- droplevels(subset(Data, is.element(Treatment, c(input $ Tr_LME_trend_baseline, input $ Tr_LME_trend_investigated))))
        Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start_LME_trend) & Timepoint <= as.numeric(input $ Day_end_LME_trend)))
        Data <- within(Data, Treatment <- relevel(Treatment, ref = input $ Tr_LME_trend_baseline))
        Data <- transform(Data, Timepoint=as.factor(Timepoint))
        Data <- transform(Data, Timepoint_ordered=as.numeric(Timepoint))
        ##-------------------------------------------------------------------------
        Model <- lmer(Response ~ 1 + Timepoint_ordered * Treatment + (1|No), data=Data)        
        beta <- fixef(Model)
        
        a <- length(input $ Tr_LME_trend_investigated)
        b <- length(beta)
        
        intercepts <- c(beta[1], beta[1] + beta[3:(3+a-1)]) 
        slopes <- c(beta[2], beta[2] + beta[(b-a+1):b])
        
        params <- data.frame(a=intercepts, b=slopes, Treatment=levels(Data $ Treatment))
        
        Data $ Fit <- fitted(Model, level=0)
        
        ggplot(Data, aes(x=Timepoint_ordered, y=Fit, group=id, col=Treatment)) +
          geom_point() + 
          geom_line(lty=3) + 
          geom_abline(data=params, aes(intercept=a, slope=b, col=Treatment),size=1.5) +
          scale_x_continuous(breaks = unique(Data $ Timepoint_ordered)) +
          ylab('Model fit') +
          xlab('\n Timepoint (ordered)')
          }
    })
    
    
    
    ##=========================================================================
    ## Model with time as factor:
    Model_LME <- reactive({
      Data <- Data()
      ##----------------------------------------------------
      Data <- droplevels(subset(Data, is.element(Treatment, c(input $ Tr_LME_baseline, input $ Tr_LME_investigated))))
      Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start_LME) & Timepoint <= as.numeric(input $ Day_end_LME)))
      Data <- within(Data, Treatment <- relevel(Treatment, ref = input $ Tr_LME_baseline))
      Data <- transform(Data, Timepoint=as.factor(Timepoint))
      ##-------------------------------------------------------------------------
      Model_LME <- lmer(Response ~ 1 + Timepoint * Treatment + (1|No), data=Data)
      return(Model_LME)
    })
    
    ## Model summary (fixed-effects only):
    output $ Model_LME_summary_FE <- renderTable({
      if(is.null(input $ data)){return(NULL)}else{
        Model_LME <- Model_LME()
        return(summary(Model_LME) $ coefficients)
      }
    }, digits=3)
    
    ## Model summary (full):
    output $ Model_LME_summary_Full <- renderPrint({
      if(is.null(input $ data)){return(NULL)}else{
        Model_LME <- Model_LME()
        return(summary(Model_LME))
      }
    })

    ##===================================================================
    ## Lsmeans for LME
    
    output $ effects_table <- renderTable({
      if(is.null(input $ data)){return(NULL)}else{
        Data  <- Data()        
        Data <- droplevels(subset(Data, is.element(Treatment, c(input $ Tr_LME_baseline, input $ Tr_LME_investigated))))
        Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start_LME) & Timepoint <= as.numeric(input $ Day_end_LME)))
        Data <- within(Data, Treatment <- relevel(Treatment, ref = input $ Tr_LME_baseline))
        Data <- transform(Data, Timepoint=as.factor(Timepoint))
        ##-------------------------------------------------------------------------
        Model_LME <- lmer(Response ~ 1 + Timepoint * Treatment + (1|No), data=Data)
        attach(Data)
        ##----------------------
        LME_eff <- lsmeans (Model_LME, ~ Treatment | Timepoint)
        detach(Data)
        LME_eff <- data.frame(summary(LME_eff))
        Timepoint <- unique(Data $ Timepoint)
        
        ES <- data.frame()
        for(i in 1:length(Timepoint)){
          rows <- which(LME_eff $ Timepoint == Timepoint[i])
          for(j in rows[2:length(rows)]){
            ES[j,1] <- 100*(1-LME_eff $ lsmean[j] / LME_eff $ lsmean[rows[1]])
          }
        }
        colnames(ES) <- c('Effect size(%)')
        return(cbind(LME_eff, ES))
      }
    }, digits=c(1,0,1,3,3,3,3,3,1))
    
    output $ LME_lsmeans_plot <- renderPlot({
      if(is.null(input $ data)){return(NULL)}else{
        Model <- Model_LME()
        Data  <- Data()
        attach(Data)
        ##----------------------
        LME_eff <- lsmeans (Model, ~ Treatment | Timepoint)
        detach(Data)
        plot(LME_eff, xlab=yLab())
      }
    })
    
    output $ LME_effects_plot <- renderPlot({
      if(is.null(input $ data)){return(NULL)}else{
        Data  <- Data()        
        Data <- droplevels(subset(Data, is.element(Treatment, c(input $ Tr_LME_baseline, input $ Tr_LME_investigated))))
        Data <- droplevels(subset(Data, Timepoint >= as.numeric(input $ Day_start_LME) & Timepoint <= as.numeric(input $ Day_end_LME)))
        Data <- within(Data, Treatment <- relevel(Treatment, ref = input $ Tr_LME_baseline))
        Data <- transform(Data, Timepoint=as.factor(Timepoint))
        ##-------------------------------------------------------------------------
        Model_LME <- lmer(Response ~ 1 + Timepoint * Treatment + (1|No), data=Data)
        attach(Data)
        ##----------------------
        LME_eff <- lsmeans (Model_LME, ~ Treatment | Timepoint)
        detach(Data)
        LME_eff <- data.frame(summary(LME_eff))
        Timepoint <- unique(Data $ Timepoint)
        
        ES <- data.frame()
        for(i in 1:length(Timepoint)){
          rows <- which(LME_eff $ Timepoint == Timepoint[i])
          for(j in rows[2:length(rows)]){
            ES[j,1] <- LME_eff $ Treatment[j]
            ES[j,2] <- LME_eff $ Timepoint[j]
            ES[j,3] <- 100*(1-LME_eff $ lsmean[j] / LME_eff $ lsmean[rows[1]])
          }
        }
        colnames(ES) <- c('Treatment', 'Timepoint', 'Effect_size')
        ES <- ES[-which(is.na(ES $ Timepoint)),]
        
      ggplot(ES, aes(x=Timepoint, y=Effect_size, group=Treatment, col=Treatment)) + 
          geom_point(size=3.5) + geom_line(lwd=1.1) + 
          scale_y_continuous(limits = c(-10,100)) +
          ylab('Effect size(%)') + 
          xlab(paste0('\n Timepoint (', input $ time_unit, ')')) +
          ggtitle(paste('Baseline treatment:', input $ Tr_LME_baseline, '\n')) + .theme
      }
    })
})## for function
