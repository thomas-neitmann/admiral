# Function (get_map)
get_map <- function(val, val_fmt){
  get_map_temp = function(input){
    output <- list()
    for(i in 1:length(input)){
      for(j in 1:length(val)){
        if(!(input[[i]] %in% val)){
          output[[i]] <- ""
        }
        else if(input[[i]] == val[[j]]){
          output[[i]] <- val_fmt[[j]]
        }
      }
    }
    return(output)
  }
  return(get_map_temp)
}

# Example - Yes / No
yn_order <- get_map(val=c("Y", "N"),
                      val_fmt=c("1", "0"))
yn_order
yn_order(c("Y", "N", "Y", "MAYBE"))

# Example - Region
region_def <- get_map(val=c("USA", "ENG", "CAN", "JAP", "FRA"),
                      val_fmt=c("North America", "Europe", "North America", "Asia", "Europe"))
region_def
region_def(c("CAN", "FRA", "JAP", "USA", "USA", "ENG", "ABC"))



