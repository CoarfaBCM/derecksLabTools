#' Signature(s) files to GMT list; split up and down (inclusive) based on log2fc
#'
#' @param signatures_dir \[type: character\] A directory containing signature files.
#' @param pattern \[type: character<regex>, default: NULL\] A regular expression to match files on read-in.
#' @param to_upper \[type: logical, default: TRUE\] Convert genes to uppercase; typically yes, lowercase genes are mice type - GSEA works with uppercase humanised genes.
#'
#' @return list<character>
#' @export
#'
#' @examples
#'

# Signatures are split into up and down genes (down inclusive)

sig2UpDownGmt <- function(signatures_dir, pattern = NULL, gsub_cols_regex = "EdgeR\\.upperquartile_LRT_RUVr_", to_upper = TRUE) {
    paths <- list.files(signatures_dir, full.names = TRUE, pattern = pattern)
    names(paths) <- list.files(signatures_dir, pattern = pattern)

    gmt <- lapply(paths, function(path) { # read all files
        return(as.data.frame(suppressWarnings(data.table::fread(path))))
    })

    gmt <- lapply(gmt, function(signature) { # rename columns
        colnames(signature) <- c("genes", gsub(gsub_cols_regex, "", colnames(signature)[2]))
        return(signature)
    })

    gmt <- lapply(gmt, function(signature) { # split up and down; concatenate signature name as pathway name with UP/DOWN
        signature <- as.data.frame(signature)
        return(list(
            up = as.character((function(df_arrays) {
                cbind(
                    rep(paste(rownames(df_arrays)[2], "UP", sep = "_"), 2),
                    rep("na", 2),
                    df_arrays
                )
            })(as.data.frame(t(signature[signature[, 2] > 0,])))[1, ]),
            down = as.character((function(df_arrays) {
                cbind(
                    rep(paste(rownames(df_arrays)[2], "DOWN", sep = "_"), 2),
                    rep("na", 2),
                    df_arrays
                )
            })(as.data.frame(t(signature[signature[, 2] <= 0,])))[1, ])
        ))
    })

    if(to_upper) { # convert to uppercase
        gmt <- lapply(gmt, function(arrs_list) { #
            return(lapply(arrs_list, function(str_array) {
                return(c(str_array[1:2], toupper(str_array[3:length(str_array)])))
            }))
        })
    }

    return(unlist(gmt, recursive = FALSE))
}
