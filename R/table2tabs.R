#' Parse Excel tables from one sheet to named tabs
#'
#' Parses tables from one Excel sheet based on an identifier, empty rows/columns must be left between tables as these are used for edge detection by the `is.na()` function. Each table on the sheet should have column"" names, the first is used for identification of tables, the second for tab names.
#' This is a tool used at our lab for quickly writing comparisons for the RNAseq analysis and then converting them to multiple tabs.
#' The typical format is; colnames: "ID", "comparison_name", where ID designates the sample ID's and comparison_name designates test/control.
#'
#' Note that you can have other content on your excel sheet as long as it does not contain the table_id string used for parsing.
#'
#' @keywords table2tabs
#' @param file String; path to a file type xlsx.
#' @param table_id String \[default "ID"\]; this is used for identifying the individual tables on a single sheet.
#' @param out_file String; the name of the output file - must have extension `.xlsx`.
#' @param return Boolean \[default FALSE\]; if TRUE returns the parsed data.
#' @return Returns if return argument set to TRUE; a list of `data.frame`s - might be useful for analysis - the primary output is the file output.
#' @examples
#' path <- system.file("extdata", "comparisons-setup.xlsx", package = "derecksLabTools")
#' table2tabs(
#'     file = path,
#'     table_id = "ID",
#'     out_file = "output-file.xlsx",
#'     return = FALSE
#' )
#'
#' @export
#'

table2tabs <- function(file = "", table_id = "ID", out_file = "", return = FALSE) {
    raw_data <- readxl::read_excel(file, col_names = FALSE)

    sub_side <- raw_data[,min(which(grepl(table_id, raw_data))):ncol(raw_data)]

    map <- rowSums(apply(sub_side, 2, function(column) {
        grepl(table_id, column)
    }))

    sub_top <- sub_side[min(which(map != 0)):nrow(sub_side),]

    map <- grepl(table_id, sub_top)

    map[which(map) + 1] <- TRUE

    tables <- sub_top[,map]

    map <- grepl(table_id, tables)

    maps <- as.list(which(map))

    maps <- lapply(maps, function(map) {
        return(c(map, map + 1))
    })

    columns <- lapply(maps, function(map) {
        return(tables[,map])
    })

    renamed_cols <- lapply(columns, function(column) {
        colnames(column) <- c("one", "two")
        return(column)
    })

    removed_extra_NA <- lapply(renamed_cols, function(column) {
        map <- is.na(column[, 1]) & is.na(column[, 2])

        # small algorithm for removing extra NAs at end
        accum <- 0L
        for (i in seq_along(map)) {
            accum <- accum + map[i]
            if(accum > 0 & map[i + 1]) {
                break
            } else {
                accum <- 0L
            }
        }
        return(column[1:(i), ])
    })

    # if the last row is not NA then add it if not pad at top
    NA_padded <- lapply(removed_extra_NA, function(col) {
        NA_frame <- (function() {
            NA_frame <- data.frame(NA, NA)
            colnames(NA_frame) <- c("one", "two")
            return(NA_frame)
        })()

        if(nrow(col) != max(which(is.na(col[, 1]) & is.na(col[, 2])))) {
            bound <- rbind(col, NA_frame)
            return(bound)
        } else {
            return(col)
        }
    })

    bound <- do.call("rbind", NA_padded)

    # starts <- grepl(table_id, bound$one)
    starts <- table_id == bound$one
    ends <- is.na(bound$one)

    start_indices <- which(starts)
    end_indices <- which(ends)
    end_indices <- c(end_indices[1:(length(start_indices) - 1)], nrow(bound))

    indices <- mapply(function(start, end) {
        start:end
    }, start_indices, end_indices, SIMPLIFY = FALSE)

    separated <- lapply(indices, function(index) {
        bound[index,]
    })

    cleaned <- lapply(separated, function(separate) {
        return(separate[!is.na(separate$one),])
    })

    col_named <- lapply(cleaned, function(clean) {
        colnames(clean) <- clean[1,]
        clean <- clean[-1,]
        return(clean)
    })

    names(col_named) <- lapply(col_named, function(col_name) {
        return(colnames(col_name)[2])
    })

    # Save results
    wb <- openxlsx::createWorkbook()

    Map(function(data, sheet) {

        openxlsx::addWorksheet(wb, sheet)
        openxlsx::writeData(wb, sheet, data)

    }, col_named, names(col_named))

    openxlsx::saveWorkbook(wb, file = out_file, overwrite = TRUE)

    if(return) {
        return(col_named)
    }
}
