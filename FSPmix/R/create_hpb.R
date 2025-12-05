# Generated from create-FSPmix.Rmd: do not edit by hand

#' Draw high probability bands
#' 
#' @param res Output from fspmix
#' @param alpha Alpha level, default is 0.05
#' @param label Label set, used to assign graph titles. If empty, titles will be automatically given Group 1 to K
#' 
#' @export
create_hpb <- function(res, alpha = 0.05,label = NULL){
  K <- nrow(res$result$mu)
  p <- ncol(res$result$mu)
  
  auto_mfrow <- function(n) {
    nr <- floor(sqrt(n))
    nc <- ceiling(n / nr)
    c(nr, nc)
  }
  par(mfrow = auto_mfrow(K))
  
  if(!is.null(label)){
    group <- attr(label$label,"levels")
    if(K>length(group)){
      group <- c(group,paste0("New", 1: (K - length(group))))
    }
  }else{
    group <- paste0("Group",1:K)
  }
  
  pred = prediction(res)
  bands = array(dim = c(2 , p , K))
  for(k in 1:K){
    x = res$data[which(pred$predict_label == k),]
    for(d in 1:p){
      h = res$result$sigma[k,d] * length(x[,d])^(-0.2)
      pad = 10*h
      rng = apply(x, 2, range)
      probs = c( (alpha/p)/2 , 1 - (alpha/p)/2 )
      interval <- matrix(c(rng[1,] - pad , rng[2,] + pad) , nrow = 2, byrow = TRUE)
      
      Fhat <- function(z) mean(pnorm((z - x[,d]) / h))
      qfun <- function(p) uniroot(function(z) Fhat(z) - p, interval = interval[,d])$root
      bands[,d,k] <- vapply(probs, qfun, numeric(1))
    }
  }
  
  for(i in 1:K){
    mean_line <- res$result$mu[i,]
    x <- seq(1,p)
    plot(x, t(mean_line), type = "l", ylim = c(0,1),lty = 1, lwd = 2, pch = 20, col = i, xlab = "", ylab = "",main = group[i])
    upper <- bands[2,,i]
    lower <- bands[1,,i]
    polygon(c(x, rev(x)), c(upper, rev(lower)), col = adjustcolor(i, alpha.f = 0.2), border = NA)
    if(i %in% label$label){
      for (j in which(label$label == i)) {
        lines(res$data[label[j,]$index,] , col = i)
      }
    }
  }
}
