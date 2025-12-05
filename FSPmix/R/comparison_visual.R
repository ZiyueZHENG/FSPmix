# Generated from create-FSPmix.Rmd: do not edit by hand

#' Model results comparison
#' 
#' @param res1 Output of fspmix function
#' @param res2 Output of fspmix function
#' @export
comparison_visual <- function(res1 , res2){
  pred1 = prediction(res1)
  pred2 = prediction(res2)
  
  # make contingency table
  make_contingency_table<-function(mem1, mem2){
    tab = table(mem1, mem2)
    tab = cbind(tab, rowSums(tab))
    tab = rbind(tab, colSums(tab))
    return(tab)
  }
  
  tab = make_contingency_table(pred1$predict_label, pred2$predict_label)
  tab_clean <- tab[1:(nrow(tab) - 1), 1:(ncol(tab) - 1)]
  rtab_clean = tab_clean / rowSums(tab_clean)
  
  rtab_long <- as.data.frame(rtab_clean) %>%
    mutate(from = rownames(rtab_clean)) %>%
    pivot_longer(cols = -from, names_to = "to", values_to = "value") %>%
    mutate(to = factor(.$to, levels = colnames(tab_clean)))
  
  # Heatmap
  heatmap <- ggplot(rtab_long, aes(x = to, y = from, fill = value)) +
    geom_tile(color = "lightgrey") +
    geom_text(aes(label = paste0(round(value * 100, 1), "%")), color = "black", size = 3) +
    scale_fill_gradient(limits = c(0, 1), low = grey(0.98), high = "blue") +
    labs(
      x = "Model 1",
      y = "Model 2",
      title = "Similarity matrix of two model prediction"
    )+
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5,size = 14,face = "bold"),
          axis.text.x = element_text(angle = 25, vjust = 1,hjust = 1),
          plot.margin = margin(t = 5, r = 5, b = 5, l = 5),
          legend.title = element_text(face = "bold"))
  
  # Convert to counts of flows
  df_counts <- as.data.frame(table(pred1$predict_label, pred2$predict_label))
  colnames(df_counts) <- c("Model_1", "Model_2", "Freq")
  
  # Alluvial plot
  alluvia <- ggplot(df_counts,
         aes(axis1 = Model_1, axis2 = Model_2, y = Freq)) +
    geom_alluvium(aes(fill = Model_2),  width = 1/12) +
    geom_stratum(width = 1/12, aes(fill = after_stat(stratum)), color = "black") +
    geom_text(stat = "stratum",
              aes(label = after_stat(stratum)),
              size = 5) +
    scale_x_discrete(limits = c("Model 1", "Model 2"), expand = c(.1, .1)) +
    theme_minimal() +
    labs(y = "Count", title = "Prediction differences between two models") +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5,size = 14, face = "bold"),
          axis.text = element_text(size = 11))
  
  alluvia/heatmap + 
    plot_layout(heights = c(3,2))
}

