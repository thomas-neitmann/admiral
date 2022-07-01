#' Define mapping of values and return a function.
#'
#' @param val An input vector of values that need to be mapped
#'
#' @param val_fmt An input vector of values to map to
#'
#'   If a mapping value is not found an empty value will be returned
#'
#' @author Nathan Rees, Maya Dhaliwal, Tamara Senior
#'
#' @details Usually this computation function can not be used with `%>%`.
#'
#' @return A character vector
#'
#' @keywords computation timing
#'
#' @export
#'
#' @examples
#'
#' # Example - Yes / No
#' yn_order <- get_map(val=c("Y", "N"),
#'                     val_fmt=c("1", "0"))
#'
#' yn_order(c("Y", "N", "Y", "MAYBE"))
#'
#' # Example - Region
#' region_def <- get_map(val=c("USA", "ENG", "CAN", "JAP", "FRA"),
#'                       val_fmt=c("North America", "Europe", "North America", "Asia", "Europe"))
#'
#' region_def(c("CAN", "FRA", "JAP", "USA", "USA", "ENG", "ABC"))
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
    return(unlist(output))
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
x <- region_def(c("CAN", "FRA", "JAP", "USA", "USA", "ENG", "ABC"))



