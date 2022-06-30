# Function within Function
func <- function(val, val_fmt){
  func_in_func = function(input){
    output = val
    return(output)
  }
  return(func_in_func)
}

func(val=c("USA", "CAN", "ENG"),
        val_fmt=c("NA", "NA", "EUR"))


# Function with unlimited arguments
test <- function(...){
  sum(...)
}

test(1,2,3)

# get_map
get_map <- function(...){
  quote(...)
  list(...)
}

get_map("Y" := 1, "N" := 0)


