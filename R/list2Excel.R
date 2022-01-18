#' Save a named list of `data.frames` | `data.tables` to and Excel workbook with multiple sheets
#'
#' @param list \[type: list<data.frame | data.table>\] A named list of `data.frame` or `data.table`; note the names should not exceed Excels max char limit of 31.
#' @param file \[type: character\] A file to save to.
#' @param ... Other arguments passed to: `openxlsx::saveWorkbook`.
#'
#' @export
#'

list2Excel <- function(list, file, ...) {
    wb <- openxlsx::createWorkbook()
    Map(function(data, sheet) {

        openxlsx::addWorksheet(wb, sheet)
        openxlsx::writeData(wb, sheet, data)

    }, list, names(list))

    openxlsx::saveWorkbook(wb, file = file, ...)
}
