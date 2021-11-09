
#' Read an excel workbook to a named list of data.tables or other type
#'
#' You can tell the function what type you want the data.frames to be coerced to. Default is data.table.
#'
#' @param path \[type: char\] a path to an excel file, read by readxl::excel_sheets.
#' @param FUN_type \[type: function | char, default: "data.table::data.table"\] a function or string matching a function name to which to format the resulting data in the list.
#' @param ... extra arguments passed to readxl::read_excel().
#'
#' @return list<data.table | dx>
#'
#' @export
#'
#' @examples
#'
#' excelList(system.file("extdata", "comparisons.xlsx", package = "derecksLabTools"), FUN_type = as.data.frame)
#'
#' excelList(system.file("extdata", "comparisons.xlsx", package = "derecksLabTools"), FUN_type = "data.table::as.data.table")
#'

excelList <- function(path, FUN_type = "data.table::data.table", ...) {
    if(!is.function(FUN_type) & is.character(FUN_type)) {
        FUN_type <- eval(parse(text = FUN_type))
    }

    sheets <- readxl::excel_sheets(path)
    names(sheets) <- sheets

    dataset <- lapply(sheets, function(sheet) {
        dx <- readxl::read_excel(path, sheet = sheet, ...)
        # browser()
        return(FUN_type(dx))
    })

    return(dataset)
}

