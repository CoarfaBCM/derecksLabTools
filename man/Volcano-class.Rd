% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Volcano.R
\docType{class}
\name{Volcano-class}
\alias{Volcano-class}
\alias{Volcano}
\title{\code{S4} class; Volcano data.table manipulated and prepared for plotting}
\value{
Volcano
}
\description{
This class takes in a \code{data.table} with specific columns in a specific format. Columns must contain: "feature" and "log2FC" columns. This data must also contain either or/and both "fdr", "p_value" columns.

Then this class manipulates this object to produce an \code{S4} class who is ready for plotting and saves all settings used to prepare the data in adjacent slots.

You can then plot this object by simply calling \code{plot(Volcano(data))}
}
\section{Slots}{

\describe{
\item{\code{data}}{data.table.}

\item{\code{statistic}}{character; which column to use as a statistic filter - either "fdr" or "p_value".}

\item{\code{statistic_cutoff}}{numeric.}

\item{\code{log2_cutoff}}{numeric.}

\item{\code{head_labels}}{numeric; how many points to be labeled; sorts data and creates a label for only top n.}
}}

\seealso{
plot-Volcano
}
