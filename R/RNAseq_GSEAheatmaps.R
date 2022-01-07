
#' Make heatmaps from combined GSEA reports after EdgeR
#'
#' @details
#' Your combined GSEA reports should look something like this:
#'
#' \figure{gsea-combined-reports.png}
#' \figure{hallmark-enrichment-heatmap.png}
#'
#' @param gsea_combined_profiles \[type: character, default: NULL\] this is a path to a prepared excel file. This file should contian your combined reports (all comparisons from GSEA bound together; use Cristian's tool to combine reports. Then combine these reports into a single excel, each tab represents comparisons per pathway collection.
#' @param clean_names_regex \[type: character, default: "EdgeR\\.TMM_Exact_|EdgeR\\.upperquartile_LRT_RUVr_|\\.rnk\\.NES"\] a regex expression to remove strings from the comparison names. Often comparisons are preceeeded by some prefix of the parameters of which the rank files were created, normalisation etc.
#' @param scale_bounds \[type: vector<numeric>, default: NULL\] if provided will set the max and min of the scale for heatmaps; affects colour intensity.
#' @param reo_order_cols \[type: vector<numeric>, default: NULL\] if provided will re-order the columns for every heatmap. You must know the order and number of columns you wish before supplying.
#' @param clust_row \[type: logical, default: FALSE\] true uses pheatmap's clustering on rows; pathways.
#' @param clust_col \[type: logical, default: FALSE\] true uses pheatmap's clustering on columns; comparisons.
#' @param show_rownames \[type: logical, default: FALSE\] true shows the rownames; pathways.
#' @param show_colnames \[type: logical, default: FALSE\] true shows the column names; comparisons.
#'
#' @return
#' @export
#'
#' @examples
#' path <- system.file(
#'     "extdata",
#'     "GSEA-combined-enrichment-profiles.xlsx",
#'     package = "derecksLabTools"
#' )
#'
#' heatmaps <- RNAseq_GSEAheatmaps(
#'     path,
#'     scale_bounds = NULL,
#'     reo_order_cols = NULL,
#'     clust_row = TRUE,
#'     clust_col = FALSE,
#'     show_rownames = TRUE,
#'     show_colnames = TRUE
#' )
#' pdf("./hallmark-enrichment-heatmap.pdf", width = 7, height = 10)
#' print(heatmaps$hallmark)
#' dev.off()


RNAseq_GSEAheatmaps <- function(gsea_combined_profiles, clean_names_regex = "EdgeR\\.TMM_Exact_|EdgeR\\.upperquartile_LRT_RUVr_|\\.rnk\\.NES", scale_bounds = NULL, reo_order_cols = NULL, clust_row = TRUE, clust_col = FALSE, show_rownames = FALSE, show_colnames = FALSE) {
    if(tools::file_ext(gsea_combined_profiles) != "xlsx") {
        stop("Input file must be .xlsx; this is created after combining GSEA reports AND putting all reports into a single excel file with named tabs per pathway collection; kegg, hallmark, gobp etc...")
    }

    sheets <- openxlsx::getSheetNames(gsea_combined_profiles)
    names(sheets) <- sheets
    dataset <- lapply(sheets, function(sheet) {
        return(openxlsx::read.xlsx(gsea_combined_profiles, sheet = sheet, rowNames = TRUE))
    })

    # set common scale to heatmaps; db refers to database/pathway collection/sheet
    if(is.null(scale_bounds)) {
        max <- lapply(dataset, function(db) {
            return(max(db))
        })

        min <- lapply(dataset, function(db) {
            return(min(db))
        })
    } else {
        max <- scale_bounds[1]
        min <- scale_bounds[2]
    }

    heatmap_bounds <- c(floor(min(unlist(min))), ceiling(max(unlist(max))))
    heatmap_bounds <- c(-max(abs(heatmap_bounds)), max(abs(heatmap_bounds)))

    heatmap_bounds <- seq(heatmap_bounds[1], heatmap_bounds[2], by = 0.25)
    colours <- grDevices::colorRampPalette(c("blue", "white", "red"))(length(heatmap_bounds))

    heatmap_breaks <- c(
        seq(min(heatmap_bounds), 0, length.out = ceiling(length(colours) / 2) + 1),
        seq(max(heatmap_bounds) / length(colours), max(heatmap_bounds), length.out = floor(length(colours) / 2))
    )

    # clean comparison names
    dataset <- lapply(dataset, function(db) {
        colnames(db) <- gsub("EdgeR\\.TMM_Exact_|EdgeR\\.upperquartile_LRT_RUVr_|\\.rnk\\.NES", "", colnames(db))
        return(db)
    })

    if(!is.null(reo_order_cols) & is.numeric(reo_order_cols)) {
        dataset <- dataset[, reo_order_cols]
    }

    ## heatmaps
    plots <- mapply(function(db, db_name) {
        db <- db[abs(rowSums(db)) > 0, , drop = FALSE]

        title <- stringr::str_interp('Pathway enrichment in ${toupper(db_name)}\n${ncol(db)} comparisons, ${nrow(db)} pathways')
        plot <- pheatmap::pheatmap(
            db,
            main = title,
            breaks = heatmap_breaks,
            color = colours,
            cluster_rows = clust_row,
            cluster_cols = clust_col,
            show_rownames = show_rownames,
            show_colnames = show_colnames,
            clustering_method = "ward.D",
            silent = TRUE
        )

        return(plot)
    }, dataset, names(dataset), SIMPLIFY = FALSE)

    return(plots)
}

