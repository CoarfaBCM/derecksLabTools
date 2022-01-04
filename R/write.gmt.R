#' Write GMT list to a formatted file.
#'
#' Adds new lines per pathway and "`\t`" as a separator.
#'
#' @param list_gmt [type: list<character>] List of GMT pathways.
#' @param output_file [type: character] Output file name.
#'
#' @export
#'
#' @examples
#'

write.gmt <- function(list_gmt, output_file) {
    list_gmt <- lapply(list_gmt, function(pathway) {
        return(c(pathway, "\n"))
    })

    list_gmt <- unlist(unname(list_gmt))

    writeLines(list_gmt, output_file, sep = "\t") # will rely on writeLines to give path errors
}
