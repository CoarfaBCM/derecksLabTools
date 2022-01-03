#' RNAseq GSEA methods citation
#'
#' Prints methods used for RNAseq and GSEA analysis, allows for variable interpolation to print a custom message.
#'
#' @param fold_changes \[type: vector<numeric>, default: 1.5\] A vector of numerics, get concatenated and formatted for printing.
#' @param normalisation_type \[type: character, default: "LRT_ruvR_upperquartile"\] Either "LRT_ruvR_upperquartile" or "TMM", depends on if replicates could be used for analysis and normalisation type.
#'
#' @include getIndex.R
#'
#' @return NULL
#' @export
#'
#' @examples
#' cite_RNAseqGSEA(fold_changes = c(1.5, 2.0), normalisation_type = "TMM")
#'
#'

cite_RNAseqGSEA <- function(fold_changes = 1.5, normalisation_type = "LRT_ruvR_upperquartile") {
    citations <- list(
        cutadapt = 'Martin, Marcel. "Cutadapt Removes Adapter Sequences from High-Throughput Sequencing Reads." EMBnet.journal, vol. 17, no. 1, 2011, p. 10., doi:10.14806/ej.17.1.200.',
        fastqc = 'Andrews, S. (2010). FastQC: A Quality Control Tool for High Throughput Sequence Data [Online] http://www.bioinformatics.babraham.ac.uk/projects/fastqc/',
        refgenome = 'Schneider, Valerie A., et al. "Evaluation of GRCh38 and De Novo Haploid Genome Assemblies Demonstrates the Enduring Quality of the Reference Assembly." Genome Research, vol. 27, no. 5, 2017, pp. 849–864., doi:10.1101/gr.213611.116.',
        multiqc = 'Ewels, Philip, et al. "MultiQC: Summarize Analysis Results for Multiple Tools and Samples in a Single Report." Bioinformatics, vol. 32, no. 19, 2016, pp. 3047–3048., doi:10.1093/bioinformatics/btw354.',
        edger = 'Robinson, M. D., et al. "EdgeR: a Bioconductor Package for Differential Expression Analysis of Digital Gene Expression Data." Bioinformatics, vol. 26, no. 1, 2009, pp. 139–140., doi:10.1093/bioinformatics/btp616.',
        edaseq = 'Risso, Davide, et al. "GC-Content Normalization for RNA-Seq Data." BMC Bioinformatics, vol. 12, no. 1, 2011, p. 480., doi:10.1186/1471-2105-12-480.',
        gsea = 'Subramanian, A., et al. "Gene Set Enrichment Analysis: A Knowledge-Based Approach for Interpreting Genome-Wide Expression Profiles." Proceedings of the National Academy of Sciences, vol. 102, no. 43, 2005, pp. 15545–15550., doi:10.1073/pnas.0506580102.',
        msigdb = 'Liberzon, A., et al. "Molecular Signatures Database (MSigDB) 3.0." Bioinformatics, vol. 27, no. 12, 2011, pp. 1739–1740., doi:10.1093/bioinformatics/btr260.',
        hallmark = 'Liberzon, Arthur, et al. "The Molecular Signatures Database Hallmark Gene Set Collection." Cell Systems, vol. 1, no. 6, 2015, pp. 417–425., doi:10.1016/j.cels.2015.12.004.'
    )

    cat(stringr::str_interp('Methods: RNA seq and GSEA processing

RNAseq data was trimmed using cutadapt[${getIndex(citations, "cutadapt")}] v1.18 and fastQC[${getIndex(citations, "fastqc")}] v0.11.9. Mapping was done with Homo_sapiens.GRCh38.101.gtf[${getIndex(citations, "refgenome")}] as a reference genome. Trim and mapping quality was assessed with the multiqc[${getIndex(citations, "multiqc")}] utility version 1.8. Differential expression analysis was done with use of the edgeR[${getIndex(citations, "edger")}] package version 3.32.1 and EDAseq[${getIndex(citations, "edaseq")}] 2.24.0. An FDR cutoff of 0.05 was selected and fold change cutoff: ${if(length(fold_changes) == 1) fold_changes else paste0(fold_changes, ", ")}; ${if(normalisation_type == "LRT_ruvR_upperquartile") "LRT (likelihood ratio test) RUVr (remove unwanted variation) upperquartile normalization was used" else if(normalisation_type == "TMM") "TMM normalization was used"}. GSEA[${getIndex(citations, "gsea")}, ${getIndex(citations, "msigdb")}] (gene set enrichment analysis) was run with GSEA version 3.0. We used msigdb[${getIndex(citations, "msigdb")}, ${getIndex(citations, "hallmark")}] 7.3 human gene set files including: c2.cp.kegg.v7.3.symbols.gmt, c2.cp.reactome.v7.3.symbols.gmt, c5.go.bp.v7.3.symbols.gmt, h.all.v7.3.symbols.gmt as reference pathways. Produced reports were filtered for an FDR cutoff of 0.25, these were then used to create heatmaps.

${paste0(paste(paste0(paste0("[", 1:length(citations)), "]"), citations, sep = " "), collapse = "\n")}'))
}
