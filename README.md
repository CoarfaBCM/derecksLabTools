# derecksLabTools

Dereck's lab tools package - installable via devtools.

## Functions

- `RNAseq_GSEAheatmaps()`: Create heatmaps from GSEA workbook.
- `table2tabs()`: Parse Excel tables from one sheet to named tabs.
- `tabs2table()`: Combine Excel sheets to single table.
- `excelList()`: Read an Excel workbook to a named list; allows defining the type of returned dataframe - default data.table.

## Tutorial

Load the library with `library("derecksLabTools")` or call every function preceeded with: `derecksLabTools::`.

### `excelList()`

Returns a list of desired type of a `data.frame` default is `data.table`. You can pass a coercion function either as a string or raw function, see usage:

```r
derecksLabTools::excelList(
    system.file("extdata", "comparisons.xlsx", package = "derecksLabTools"),
    FUN_type = as.data.frame
)

derecksLabTools::excelList(
    system.file("extdata", "comparisons.xlsx", package = "derecksLabTools"),
    FUN_type = "data.table::as.data.table"
)
```

### `RNAseq_GSEAheatmaps()`

Takes in a compiled GSEA report and creates heatmaps.

Input data format as follows:

![](man/figures/gsea-combined-reports.png)

Here is an example of the output:

![](man/figures/hallmark-enrichment-heatmap.png)

Usage:

```r
path <- system.file(
    "extdata",
    "GSEA-combined-enrichment-profiles.xlsx",
    package = "derecksLabTools"
)
#'
heatmaps <- derecksLabTools::RNAseq_GSEAheatmaps(
    path,
    scale_bounds = NULL,
    reo_order_cols = NULL,
    clust_row = TRUE,
    clust_col = FALSE,
    show_rownames = TRUE,
    show_colnames = TRUE
)

pdf("./hallmark-enrichment-heatmap.pdf", width = 7, height = 10)
print(heatmaps$hallmark)
dev.off()
```

### `table2tabs()`

Parse Excel tables from one sheet to named tabs

Parses tables from one Excel sheet based on an identifier, empty rows/columns must be left between tables as these are used for edge detection by the `is.na()` function. Each table on the sheet should have column"" names, the first is used for identification of tables, the second for tab names.

This is a tool used at our lab for quickly writing comparisons for the RNAseq analysis and then converting them to multiple tabs.

The typical format is; colnames: "ID", "comparison_name", where ID designates the sample ID's and comparison_name designates test/control.

Note that you can have other content on your excel sheet as long as it does not contain the table_id string used for parsing.

Input:

![](figures/table.png)

Output:

![](figures/tabs.png)

Arguments:

- `file` String; path to a file type xlsx.
- table_id String \[default "ID"\]; this is used for identifying the individual tables on a single sheet.
- `out_file` String; the name of the output file - must have extension `.xlsx`.
- `return` Boolean \[default FALSE\]; if TRUE returns the parsed data.
    - `Returns`: if return argument set to TRUE; a list of `data.frame`s - might be useful for analysis - the primary output is the file output.

```r
derecksLabTools::table2tabs(
    file = "./data/table2tabs/comparisons-setup.xlsx",
    table_id = "ID",
    out_file = "output-file.xlsx",
    return = FALSE
)
```

### `tabs2table()`

Combine all sheets (tabs) from one or more Excel workbooks to a single table (an index is generated - first tab), padding is added (empty rows and columns) between the indvidual tables. This is useful for getting an overview of your data and avoiding having to click n tabs.

Input:

![](figures/tabs.png)

Output:

![](figures/table.png)

Arguments:

- `dir` String; path to a directory; this will read all `.xlsx` files at this location.
- `columns` Integer \[default 3\]; defines the number of columns to split the combined tables over. This splits the data and thus avoids having to scroll over a large amount of tables.
- `out_file` String; the name of the output file - must have extension `.xlsx`.
- `return` Boolean \[default FALSE\]; if TRUE returns the parsed data.
    - `Returns` if return arguemnt set to TRUE; a list of `data.frame`s - might be useful for analysis - the primary output is the file output.

```r
derecksLabTools::tabs2table(
    dir = "./mycomparisons-are-here/",
    columns = 3,
    out_file = "output-file.xlsx",
    return = FALSE
)
```

## Install

Use `devtools` to install this package:

```r
devtools::install_github("CoarfaBCM/derecksLabTools", force = TRUE)
library("derecksLabTools")
```
