
#' @title \code{S4} class; does sva::ComBat_seq batch correction
#' @author Dereck de Mezquita
#'
#' This class with its constructor makes it easy to do batch correction. Simply provide the list of \code{data.table}s to the class instantiator. This will return the corrected dataset along with PCA plots of before and after in a list.
#'
#' @slot corrected data.table.
#' @slot batches list.
#' @slot batch_map data.table.
#' @slot qc_plots list.
#'
#' @return
#' @export
combatCorrected <- setClass(
    "combatCorrected",
    slots = list(
        corrected = "data.table",
        batches = "list",
        batch_map = "data.table",
        qc_plots = "list"
    ),
    prototype = list(
        corrected = data.table::data.table(),
        batches = list( data.table::data.table() ),
        batch_map = data.table::data.table()
    ),
    validity = function(object) {
        if(all(unique(sapply(object@batches, "class")) != c("data.table", "data.frame"))) {
            stop('Slot "batches" must be a list of data.tables')
        }

        invisible(lapply(object@batches, function(batch) {
            if(all(!c("GeneID", "GeneSymbol", "GeneBiotype") %in% colnames(batch))) {
                stop('The batches must contain the column names: "GeneID", "GeneSymbol", "GeneBiotype".')
            }
        }))

        return(TRUE)
    }
)

setMethod("initialize", "combatCorrected", function(.Object, ...) {
    .Object <- callNextMethod(.Object, ...)

    common_cols <- c("GeneID", "GeneSymbol", "GeneBiotype")

    bound <- Reduce(function(...) {
        return(merge(..., by = common_cols))
    }, .Object@batches)

    col_names <- lapply(1:length(.Object@batches), function(index) {
        return(data.table::data.table(
            col_name = dtcolnames(.Object@batches[[index]], common_cols),
            batch = index
        ))
    })

    .Object@batch_map <- data.table::rbindlist(col_names, use.names = TRUE)

    annotation <- bound[, ..common_cols]

    # Combat-seq normalisation
    corrected <- sva::ComBat_seq(
        counts = to.matrix(bound[, -c("GeneSymbol", "GeneBiotype")], id.col = "GeneID"),
        batch = .Object@batch_map$batch,
        group = NULL
    )

    corrected <- data.table::as.data.table(corrected, keep.rownames = "GeneID")

    .Object@corrected <- merge(corrected, annotation, by = "GeneID")

    data.table::setcolorder(.Object@corrected, c(common_cols, setdiff(colnames(.Object@corrected), common_cols)))

    #----
    message('Calculating PCA.')
    corrected_flipped <- data.table::transpose(corrected, keep.names = "sample", make.names = "GeneID")
    raw_flipped <- data.table::transpose(bound[, -c("GeneSymbol", "GeneBiotype")], keep.names = "sample", make.names = "GeneID")

    corrected_prcomp <- prcomp(to.data.frame(corrected_flipped, id.col = "sample"))
    raw_prcomp <- prcomp(to.data.frame(raw_flipped, id.col = "sample"))

    .Object@qc_plots <- list(
        corrected = {
            ggplot2::autoplot(corrected_prcomp, colour = .Object@batch_map$batch) +
                ggplot2::labs(title = "sva::ComBat_seq corrected")
        },
        raw = {
            ggplot2::autoplot(raw_prcomp, colour = .Object@batch_map$batch) +
                ggplot2::labs(title = "Uncorrected")
        }
    )

    return(.Object)
})
