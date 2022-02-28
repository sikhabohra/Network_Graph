suppressMessages(library(plumber))
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(sqldf))
suppressMessages(library(rlist))

#' @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* @param df data frame of variables
#* @get /hierarchy
#* @serializer unboxedJSON
function() {
  tryCatch({
    data <- read.csv("data.csv")
    dataset <- sqldf("SELECT * FROM data")
    totalrow = nrow(dataset)
    print(totalrow)
    
    node <- list()
    line <- list()
    group <- list()
    
    count_node <-1
    count <- 1
    
    # Getting nodes
    for(REC in 1:totalrow) {
      KEY <- dataset[REC,"KEY"]
      FROM <- dataset[REC,"FROM"]
      TO <- dataset[REC,"TO"]
      TITLE <- dataset[REC,"TITLE"]
      GROUP <- dataset[REC, "GROUP"]
      STATUS <- dataset[REC, "STATUS"]
      ICON <- dataset[REC, "ICON"]
      LABEL0 <- dataset[REC, "LABEL0"]
      VALUE0 <- dataset[REC, "VALUE0"]
      LABEL1 <- dataset[REC, "LABEL1"]
      VALUE1 <- dataset[REC, "VALUE1"]
      
      # Get attributes
      attr1 <- list()
      attr1 <- c(attr1, label=LABEL0)
      attr1 <- c(attr1, value=VALUE0)
      
      attr2 <- list()
      attr2 <- c(attr2, label=LABEL1)
      attr2 <- c(attr2, value=VALUE1)
      
      attrF <- list()
      attrF <- c(attrF, list(attr1))
      attrF <- c(attrF, list(attr2))
           
      data <- list()
      data <- c(data, key=count_node-1)
      data <- c(data, title=TITLE)
      data <- c(data, group=GROUP)
      data <- c(data, status=STATUS)
      data <- c(data, icon=ICON)
      data <- c(data, attributes=list(attrF))
      
      if(REC > 1) {
        x <- list.find(node, title==TITLE, 1)
        if(length(x) == 0 ) {
          node[count_node] <- list(data)
          count_node <- count_node + 1
        }
      } else {
        node[count_node] <- list(data)
        count_node <- count_node + 1
      }
      
      # Get lines
      if(!is.na(FROM)) {
        data_line <- list()
        data_line <- c(data_line, from=FROM)
        data_line <- c(data_line, to=TO)
        line[count] <- list(data_line)
        count <- count + 1
      }
    }

    #group
    group1 <- list()
    group1 <- c(group1, key=1)
    group1 <- c(group1, title="Phase One")
    group1 <- list(group1)
    
    group2 <- list()
    group2 <- c(group2, key=2)
    group2 <- c(group2, title="Phase Two")
    group2 <- list(group2)
    
    group3 <- list()
    group3 <- c(group3, key=3)
    group3 <- c(group3, title="Phase Three")
    group3 <- list(group3)
    
    group <- list()
    group <- c(group, group1)
    group <- c(group, group2)
    group <- c(group, group3)
    
    # Getting final result
    dataF <- list()
    dataF <- c(dataF, nodes=list(node))
    dataF <- c(dataF, lines=list(line))
    dataF <- c(dataF, groups=list(group))
    
    list(dataF)
  }, error = function(err){
    print(err)
    list(err)
  })
}
