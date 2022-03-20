# new s3 generic
#' @title \code{S3} generic; convert to matrix **move** column to \code{rownames}
#' @author Dereck de Mezquita
#'
#' @description
#' Useful when working with \code{data.table}s; cannot have \code{rownames}. Other methods (\code{as.matrix}, \code{data.table::setDF}) allow to convert to a \code{data.frame} but then another step is necessary to move an identifier column to \code{rownames}. This function allows the two in one step.
#'
#' @param x [type: data.table] A \code{data.table} object with an identifier column.
#' @param ...
#'
#' @return matrix
#' @export
#'
#' @rdname to.matrix
to.matrix <- function(x, ...) {
    UseMethod("to.matrix")
}

# convert to matrix and move column to rownames
#' @rdname to.matrix
#' @method to.matrix data.table
#' @exportS3Method to.matrix data.table
to.matrix.data.table <- function(x, id.col = NULL, drop.id.col = TRUE) {
    ans = data.table::copy(x)

    if(!is.null(id.col)) {
        data.table::setDF(ans, rownames = ans[, get(id.col)])
        if(drop.id.col) {
            ans[, id.col] = NULL
            ans = as.matrix(ans)
        }
    } else {
        data.table::setDF(ans)
        ans = as.matrix(ans)
    }

    ans
}
