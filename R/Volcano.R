
#' \code{S4} class; Volcano data.table manipulated and prepared for plotting
#'
#' @description
#' This class takes in a \code{data.table} with specific columns in a specific format. Columns must contain: "feature" and "log2FC" columns. This data must also contain either or/and both "fdr", "p_value" columns.
#'
#' Then this class manipulates this object to produce an \code{S4} class who is ready for plotting and saves all settings used to prepare the data in adjacent slots.
#'
#' You can then plot this object by simply calling \code{plot(Volcano(data))}
#'
#' @slot data data.table.
#' @slot statistic character; which column to use as a statistic filter - either "fdr" or "p_value".
#' @slot statistic_cutoff numeric.
#' @slot log2_cutoff numeric.
#' @slot head_labels numeric; how many points to be labeled; sorts data and creates a label for only top n.
#'
#' @return Volcano
#' @export
#' @seealso plot-Volcano
Volcano <- setClass(
    "Volcano",
    slots = list(
        data = "data.table",
        statistic = "character",
        statistic_cutoff = "numeric",
        log2_cutoff = "numeric",
        head_labels = "numeric"
    ),
    prototype = list(
        data = data.table::data.table(),
        statistic = "fdr",
        statistic_cutoff = 0.25,
        log2_cutoff = log2(1.5),
        head_labels = 10
    ),
    validity = function(object) {
        if(all(colnames(object@data) %in% c("feature", "log2FC"))) {
            stop(stringr::str_interp('The data must contain columns "feature", and "log2FC"; received ${colnames(object@data)}'))
        }

        if(sum(c("fdr", "p_value") %in% colnames(object@data)) != 2) {
            stop(stringr::str_interp('The data must contain columns "fdr", and or "p_value"; received ${colnames(object@data)}'))
        }

        if(length(object@statistic) != 1) {
            stop('Slot "statistic" must be of type character length of 1.')
        }

        if(length(object@statistic_cutoff) != 1) {
            stop('Slot "statistic" must be of type numeric length of 1.')
        }

        if(length(object@log2_cutoff) != 1) {
            stop('Slot "log2_cutoff" must be of type numeric length of 1.')
        }

        if(length(object@head_labels) != 1) {
            stop('Slot "head_labels" must be of type numeric length of 1.')
        }
    }
)

setMethod("initialize", "Volcano", function(.Object, ...) {
    .Object <- callNextMethod(.Object, ...)

    copy <- data.table::copy(.Object@data)

    copy <- copy[base::order(abs(log2FC), -get(.Object@statistic), decreasing = c(TRUE, FALSE)),]

    # add labels column; NA for no label created on plot function; already sorted?
    copy[, sig_label := c(head(feature, .Object@head_labels), rep(NA_character_, nrow(copy) - .Object@head_labels))]

    # add colours to the object
    copy[, highlight := data.table::fcase(
        log2FC < -.Object@log2_cutoff & fdr < .Object@statistic_cutoff, "blue",
        log2FC > .Object@log2_cutoff & fdr < .Object@statistic_cutoff, "red",
        default = "black"
    )]

    .Object@data <- copy

    return(.Object)
})

#' \code{S4} method for \code{Volcano} \code{S4} class
#'
#' @description
#' Prepare a \code{Volcano} class using the constructor, be sure to set your desired parameters. Then plot.
#'
#' @param Volcano
#'
#' @return gg ggplot
#'
#' @export
setMethod("plot", "Volcano", function(x = object, title = "", subtitle = "", label = TRUE, ...) {
    ggplot2::ggplot(x@data, ggplot2::aes(x = log2FC, y = -log10(get(x@statistic)), colour = highlight)) +
        ggplot2::geom_point(alpha = 0.5, size = 2) +
        ggplot2::scale_color_identity(guide = "legend", labels = c("Up-regulated", "Not significant", "Down-regulated"), breaks = c("red", "black", "blue")) +
        ggplot2::scale_y_continuous(n.breaks = 10, labels = function(x) {
            scales::label_number_si(accuracy = 0.005)(x)
        }) +
        {if(any(-log10(x@data[["fdr"]]) > -log10(x@statistic_cutoff))) {
            ggplot2::geom_hline(yintercept = -log10(x@statistic_cutoff), linetype = "dashed", colour = "goldenrod", size = 0.75, alpha = 0.5)
        }} +
        {if(any(x@data$log2FC > x@log2_cutoff)) {
            ggplot2::geom_vline(xintercept = x@log2_cutoff, linetype = "dashed", colour = "red", size = 0.75, alpha = 0.5)
        }} +
        {if(any(x@data$log2FC < -x@log2_cutoff)) {
            ggplot2::geom_vline(xintercept = -x@log2_cutoff, linetype = "dashed", colour = "blue", size = 0.75, alpha = 0.5)
        }} +
        {if(label) {
            ggrepel::geom_text_repel(ggplot2::aes(label = sig_label), show.legend = FALSE)
        }} +
        ggplot2::labs(
            title = title,
            subtitle = subtitle,
            caption = stringr::str_interp('${sum(x@data$highlight != "black")}/${nrow(x@data)} signficant; ${sum(x@data$highlight == "blue")} down, ${sum(x@data$highlight == "red")} up\n${x@statistic}: ${x@statistic_cutoff}, log2FC: ${round(x@log2_cutoff, 4)}, linear FC: ${round(2 ^ x@log2_cutoff, 4)}'),
            x = 'log2(fold change)',
            y = stringr::str_interp('-log10(${x@statistic})')
        )
})
