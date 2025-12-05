# Generated from create-FSPmix.Rmd: do not edit by hand

#' Draw membership heatmap
#' 
#' @param res Output of fspmix function
#' @export
draw_heatmap <- function(res){
  mat <- res$result$resp
  pred <- prediction(res)
  
  heat_df <- mat %>%                            
    as.data.frame() %>%
    rownames_to_column(var = "id") %>%        
    mutate(label = pred$predict_label) %>%          
    pivot_longer(       
      cols      = -c(id, label),  
      names_to  = "fraction",
      values_to = "probability"
    ) %>% 
    arrange(label) %>% 
    mutate(
      id       = factor(id,       levels = rev(unique(id))), 
      fraction = factor(fraction, levels = unique(fraction)),
      label = factor(label)
    )
  
  
  ggplot(heat_df, aes(x = fraction, y = id, fill = probability)) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "blue") +
    ggnewscale::new_scale_fill() +  
    geom_tile(aes(x = 0, fill = factor(label)), width = 0.25) +
    theme_minimal() +
    theme(axis.title      = element_blank(),
          axis.text.x     = element_text(angle = 45, hjust = 1),
          axis.text.y     = element_blank(),  
          axis.ticks.y    = element_blank(),
          panel.grid      = element_blank())
}

