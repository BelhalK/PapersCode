# load("Rdata/final_FI.RData")
library("mlxR")
library("rlist")
library("psych")
library("coda")
library("Matrix")
library(abind)
require(ggplot2)
require(gridExtra)
require(reshape2)


source('R/aaa_generics.R') 
source('R/compute_LL.R') 
source('R/func_aux.R') 
source('R/func_distcond.R') 
source('R/func_FIM.R')
source('R/func_plots.R') 
source('R/func_simulations.R') 
source('R/main.R')
source('R/main_initialiseMainAlgo.R') 
source('R/main_mstep.R') 
source('R/SaemixData.R')
source('R/SaemixModel.R')
source('R/SaemixRes.R')
source('R/SaemixObject.R') 
source('R/zzz.R')

#new
source('R/main_estep.R')
source('R/main_estep_fi.R')
source('R/main_mstep_vr.R') 
source('R/main_mstep_fi2.R') 
source('R/main_fi.R') 
source('R/mixtureFunctions.R')
source('R/plots.R')




K1 = 200
K2 = 2
iter.mcmc = c(2,2,2,0)

iterations = 0:(K1+K2-1)
end = K1+K2
nchains = 1


### BATCH ###
options<-list(seed=39546,map=F,fim=F,ll.is=F,save.graphs=FALSE,nb.chains = nchains,
  nbiter.mcmc = iter.mcmc, nbiter.saemix = c(K1,K2),nbiter.sa=0,displayProgress=FALSE,
  nbiter.burn =0, map.range=c(0), nb.replacement=100,sampling='randomiter', algo="full")
fit.ref<-saemix(saemix.model,saemix.data,options)
fit.ref <- data.frame(fit.ref$param)
fit.ref <- cbind(iterations, fit.ref[-1,])

### INCREMENTAL ###
options.50<-list(seed=seed0,map=F,fim=F,ll.is=F,save.graphs=FALSE,nb.chains = nchains, 
  nbiter.mcmc = iter.mcmc, nbiter.saemix = c(K1,K2),displayProgress=FALSE, map.range=c(0),
  nbiter.sa=0,nbiter.burn =0, nb.replacement=50,sampling='seq',algo="minibatch")
# start_time <- Sys.time()
fit.50<-saemix(saemix.model,saemix.data,options.50)
# end_time <- Sys.time()
# end_time - start_time
fit.50 <- data.frame(fit.50$param)
fit.50 <- cbind(iterations, fit.50[-1,])

### Variance Reduced ###
options.vr.50<-list(seed=seed0,map=F,fim=F,ll.is=F,save.graphs=FALSE,nb.chains = nchains,
  nbiter.mcmc = iter.mcmc, nbiter.saemix = c(K1,K2),displayProgress=FALSE, map.range=c(0),
  nbiter.sa=0,nbiter.burn =0, nb.replacement=50,sampling='randomiter',algo="vr", rho =0.1)
# start_time <- Sys.time()
fit.vr.50<-saemix(saemix.model,saemix.data,options.vr.50)
# end_time <- Sys.time()
# end_time - start_time
fit.vr.50 <- data.frame(fit.vr.50$param)
fit.vr.50 <- cbind(iterations, fit.vr.50[-1,])

fit.ref.scaled <- fit.ref
fit.50.scaled <- fit.50
fit.50.scaled$iterations = fit.50.scaled$iterations*0.5
fit.50.vr.scaled <- fit.vr.50
fit.50.vr.scaled$iterations = fit.50.vr.scaled$iterations*0.5
#black, blue, red, yellow, pink
graphConvMC_5(fit.ref.scaled,fit.50.scaled,fit.50.scaled,fit.50.scaled,fit.50.vr.scaled)


# ### Fast Iterative ###
options.fi.50<-list(seed=seed0,map=F,fim=F,ll.is=F,save.graphs=FALSE,nb.chains = nchains,
  nbiter.mcmc = iter.mcmc, nbiter.saemix = c(K1,K2),displayProgress=FALSE,map.range=c(0),
  nbiter.sa=0,nbiter.burn =0, nb.replacement=50,sampling='randomiter',algo="fi", rho =0.1)
fit.fi.50<-saemix.fi(saemix.model,saemix.data,options.fi.50)

fit.fi.50 <- data.frame(fit.fi.50$param)
fit.fi.50 <- cbind(iterations, fit.fi.50[-1,])
fit.50.fi.scaled <- fit.fi.50
fit.50.fi.scaled$iterations = fit.50.fi.scaled$iterations*0.5
graphConvMC_5(fit.ref.scaled,fit.50.scaled,fit.50.scaled,fit.50.fi.scaled,fit.50.vr.scaled)
