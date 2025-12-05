# Generated from create-FSPmix.Rmd: do not edit by hand

#' Using AIC to choose the best h_0
#' 
#' @param data Data in matrix form(n * p). Can be the data result from prepare_data
#' @param label Label set. Can be the label result from prepare_data
#' @param max_new_clust Maximum number of new cluster. Default is 1
#' @param bandwidth Smooth bandwidth
#' @param max_iter Maximum iteration
#' @param min_gap Minimum difference of likelihood
#' @param nrep Number of repetitions
#' @export
aic_fspmix <- function(data , label , max_new_clust = 1, bandwidth = 1,
                       max_iter = 1000, min_gap = 0.1, nrep = 10){
  d = dim(data)[2]
  K = length(unique(label$label))
  
  AIC = rep(0 , max_new_clust + 1)
  
  res = fspmix(data = data, label = label , num_clust = K,
                               bandwidth = bandwidth, max_iter = max_iter ,
                               min_gap   = min_gap , nrep  = nrep)
  AIC[1] = K * 2 * d - res$likelihood
  for(i in 1:(max_new_clust)){
    res = fspmix(data = data, label = label , num_clust = K + i ,
                               bandwidth = bandwidth, max_iter = max_iter ,
                               min_gap   = min_gap , nrep  = nrep)
    AIC[i+1] = (i + K) * 2 * d - res$likelihood
  }
  
  return(list(AIC = AIC,
              best_K0 = which.min(AIC) - 1))
}
