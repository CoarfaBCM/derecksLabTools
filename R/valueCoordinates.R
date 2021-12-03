
#' Coordinates of X values in a data.table|data.frame
#'
#' Sometimes knowing NAs or X value are present in your data is not enough, you want to know where exactly.
#'
#' This function does:
#'
#' data == value | is.na(data)
#'
#' To create a truth table and then retrieves the column and row of where the value occurred as a data.frame.
#'
#' @param dt \[type: data.table | data.frame\]
#' @param value \[type: ANY, default: NA\]
#'
#' @return data.frame
#' @export
#'
#' @examples
#' test <- head(iris, 10)
#' test[3, 1] <- NA
#'
#' valueCoordinates(test, value = NA)
#'

valueCoordinates <- function(obj, value = NA) {
	if(is.na(value)) {
		truths <- is.na(obj)
	} else {
		truths <- obj == value
	}

	# if(sum(truths) == 0) {
	# 	return(stringr::str_interp('Value ${value} not found.'))
	# }

	r <- apply(truths, 2, function(x) {
		if(any(which(x))) {
			return(unname(which(x)))
		} else {
			return(NA)
		}
	})

	c <- apply(truths, 1, function(y) {
		if(any(which(y))) {
			return(unname(which(y)))
		} else {
			return(NA)
		}
	})

	r <- unname(r[!is.na(r)])
	c <- unname(c[!is.na(c)])

	return(data.frame(column = unlist(c), row = unlist(r)))
}
