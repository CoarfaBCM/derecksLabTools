#' Read a .gmt pathway type file as a list.
#'
#' @param file \[type: character\] Path to the file.
#' @param remove_description \[type: logical, default: FALSE\] Whether to remove description (second element of pathway; first is pathway name) of the pathway.
#'
#' @return list<character>
#' @export
#'

read.gmt <- function(file, remove_description = FALSE) {
    if(!grepl("\\.gmt$", file)[1]) {
        stop('Must be a ".gmt" file')
    }

    geneSetDB <- readLines(file) # read in the gmt file as a vector of lines
    geneSetDB <- strsplit(geneSetDB, "\t") # convert from vector of strings to a list
    names(geneSetDB) <- sapply(geneSetDB, "[", 1) # move the names column as the names of the list

    if(remove_description) {
        geneSetDB <- lapply(geneSetDB, "[", -2) # remove description
    }

    geneSetDB <- lapply(geneSetDB, function(x) {
        return(x[which(x != "")])
    }) # remove empty strings

    return(geneSetDB)
}
