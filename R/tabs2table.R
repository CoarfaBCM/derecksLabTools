#' Combine Excel sheets to single table
#'
#' Combine all sheets (tabs) from one or more Excel workbooks to a single table (an index is generated - first tab), padding is added (empty rows and columns) between the indvidual tables. This is useful for getting an overview of your data and avoiding having to click n tabs.
#' @keywords tabs2table
#' @param path \[type: character\] A path to a directory; this will read all `.xlsx` files at this location.
#' @param output \[type: character, default: "compiled-comparisons.xlsx"\] The name of the output file - must have extension `.xlsx`.
#' @param columns \[type: numeric, default: 3\] Integer defines the number of columns to split the combined tables over. This splits the data and thus avoids having to scroll over a large amount of tables.
#' @param return \[type: logical, default: FALSE\] Boolean if TRUE returns the parsed data.
#' @param ... Extra arguments to passed to \code{openxlsx::saveWorkbook}
#'
#' @return Returns if return arguemnt set to TRUE; a list of `data.frame`s - might be useful for analysis - the primary output is the file output.
#'
#' @examples
#' dir.create("./test")
#' file.copy(system.file("extdata", "comparisons.xlsx", package = "derecksLabTools"), "./test")
#' tabs2table(
#'     path = "./test",
#'     output = "output-file.xlsx",
#'     columns = 3,
#'     return = FALSE,
#'     overwrite = TRUE
#' )
#'
#' tabs2table(
#'     path = "./test/comparisons.xlsx",
#'     output = "output-file.xlsx",
#'     columns = 3,
#'     return = FALSE,
#'     overwrite = TRUE
#' )
#'
#' @export
#'

tabs2table <- function(path, output = "compiled-comparisons.xlsx", columns = 3, return = FALSE, ...) {
    if(fs::is_dir(path)) {
        path <- list.files(path, full.names = TRUE, recursive = FALSE)
    }

    names(path) <- lapply(path, "basename")

    comparisons <- lapply(path, function(path) {
        sheets <- readxl::excel_sheets(path)
        names(sheets) <- sheets
        return(lapply(sheets, function(sheet) {
            return(as.data.frame(readxl::read_excel(path, sheet = sheet)))
        }))
    })

    comparison_file_index <- mapply(function(file, file_name) {
        comparison_from_file <- data.frame(names(file))
        comparison_from_file$file <- file_name
        comparison_from_file <- comparison_from_file[, c(2, 1)]
        colnames(comparison_from_file) <- c("", "")
        return(comparison_from_file)
    }, comparisons, names(comparisons), SIMPLIFY = FALSE)

    comparison_file_index <- do.call("rbind", unname(comparison_file_index))

    colnames(comparison_file_index) <- c("file", "comparisons")

    comparisons <- unlist(comparisons, recursive = FALSE)

    na_bound <- lapply(comparisons, function(comparison) {
        na_frame <- data.frame(NA, NA)
        colnames(na_frame) <- colnames(comparison)
        return(rbind(comparison, na_frame))
    })

    colsnames_to_row <- lapply(na_bound, function(na_bind) {
        return(rbind(colnames(na_bind), na_bind))
    })

    unnamed_cols <- lapply(colsnames_to_row, function(list) {
        colnames(list) <- c("", "")
        return(list)
    })

    num_per_array <- ceiling(length(unnamed_cols) / columns)
    num_per_array <- if(num_per_array < 1) 1 else num_per_array

    num_arrays <- ceiling(length(unnamed_cols) / num_per_array)

    if(num_arrays * num_per_array < length(comparisons)) stop('Not accounting for all comparisons.')

    arrays <- vector(mode = "list", length = num_arrays)
    for (i in 1:num_arrays) {
        arrays[[i]] <- 1:num_per_array

        print(arrays[[i]])
    }

    if(num_arrays > 1) {
        accumulator <- arrays[[1]][length(arrays[[1]])]
        for (k in 2:length(arrays)) {
            arrays[[k]] <- arrays[[k]] + accumulator
            accumulator <- arrays[[k]][length(arrays[[k]])]
        }
    }

    array_of_lists <- lapply(arrays, function(array) {
        return(unnamed_cols[array])
    })
    #-----

    bound <- lapply(array_of_lists, function(list) {
        return(do.call("rbind", unname(list)))
    })

    bound_na <- lapply(bound, function(binds) {
        frame_na <- cbind(rep(NA, nrow(binds)))
        bound_na <- cbind(binds, frame_na)
        colnames(bound_na) <- rep("", ncol(bound_na))
        return(bound_na)
    })

    # pad rows
    max_length <- max(unlist(lapply(bound_na, "nrow")))

    padded <- lapply(bound_na, function(bind) {
        if(nrow(bind) < max_length) {
            padding <- vector(mode = "list", length = max_length - nrow(bind))
            for (i in seq_along(padding)) {
                padding[[i]] <- rep(NA, ncol(bind))
            }

            bound_padding <- as.data.frame(do.call("rbind", padding))

            colnames(bound_padding) <- rep("", ncol(bound_padding))

            return(rbind(bind, bound_padding))
        } else {
            return(bind)
        }
    })

    all_bound <- do.call("cbind", padded)

    colnames(all_bound) <- rep("", ncol(all_bound))

    bound_indexed <- list(
        index = comparison_file_index,
        all_comparisons = all_bound
    )

    wb <- openxlsx::createWorkbook()

    Map(function(data, sheet) {

        openxlsx::addWorksheet(wb, sheet)
        openxlsx::writeData(wb, sheet, data)

    }, bound_indexed, names(bound_indexed))

    openxlsx::saveWorkbook(wb, file = output, ...)

    if(return) {
        return(bound_indexed)
    }
}
