#' Summarise how many genes up and down from a combined signature file
#'
#' The combined signature file should be produced by CoarfaLab-tools; and of the format: first column for rownames, subsequent columns comparison names, values fold changes.
#'
#' \figure{combined-sig.log2.png}
#'
#' @param combined_signatures_file \[type: character\] A combined signature file; produced by running CoarfaLab-tools: `combineGeneSignatures.cc.py -g "sig.*" -o combined-sig &> log.combined-sig`
#' @param output_file \[type: character\] Output file, csv format.
#'
#' @return data.table
#' @export
#'
#' @examples
#'

summariseSignatures <- function(combined_signatures_file, output_file, gsub_rows_regex = "EdgeR\\.upperquartile_LRT_RUVr_|_FC_1\\.25_FDR_0\\.05") {
    data <- openxlsx::read.xlsx(combined_signatures_file, rowNames = TRUE)

    up <- lapply(data, function(col) {
        return(sum(col > 0))
    })

    down <- lapply(data, function(col) {
        return(sum(col < 0))
    })

    summaries <- cbind(t(as.data.frame(up)), t(as.data.frame(down)), unlist(up) + unlist(down))

    colnames(summaries) <- c("up", "down", "total")

    rownames(summaries) <- gsub(gsub_rows_regex, "", rownames(summaries))

    write.csv(summaries, file = output_file)

    return(data.table::data.table(summaries, keep.rownames = "comparison"))
}
