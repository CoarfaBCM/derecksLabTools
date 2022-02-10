#' Get the data column names from data.table; exclude ID col
#'
#' @param object \[type: data.table\] A data.table with an identifier column or more.
#' @param excluded \[type: vector<character>, default: "sample"\] A character vector of one or more column names to exclude.
#'
#' @return character<vector>
#' @export
#'

dtcolnames <- function(object, excluded = "sample") {
    if(!data.table::is.data.table(object)) {
        stop('Object must be of class data.table.')
    }

    return(colnames(object)[!colnames(object) %in% excluded])
}
