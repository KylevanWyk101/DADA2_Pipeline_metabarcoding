#!/bin/bash

# Function to display loading message
loading_message() {
    echo -e "\n$1"
    echo "------------------------------------"
    sleep 1
}

# Check if QIIME 2 environment is activated
if [[ -z "$CONDA_DEFAULT_ENV" || "$CONDA_DEFAULT_ENV" != "qiime2-amplicon-2024.10" ]]; then
    echo "Error: QIIME 2 environment (qiime2-amplicon-2024.10) not activated."
    echo "Please activate it with: conda activate qiime2-amplicon-2024.10"
    exit 1
fi
loading_message "🧬 QIIME 2 environment verified for impala rbcl analysis"

# Check if manifest file exists
if [[ ! -f "impala_manifest_rbcl.tsv" ]]; then
    echo "Error: Manifest file 'impala_manifest_rbcl.tsv' not found in current directory."
    exit 1
fi
loading_message "📍 Manifest file verified in current working directory"

# Create output directory
mkdir -p I_rbcl_output
loading_message "📂 Created output directory for I_rbcl results"

# Import data
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path impala_manifest_rbcl.tsv \
  --input-format SingleEndFastqManifestPhred33V2 \
  --output-path I_rbcl_output/I_imported_rbcl.qza
loading_message "🧬 Imported impala rbcl sequences successfully"

# Visualize imported data
qiime demux summarize \
  --i-data I_rbcl_output/I_imported_rbcl.qza \
  --o-visualization I_rbcl_output/I_imported_rbcl.qzv
loading_message "📊 Generated visualization of imported I_rbcl sequences"

# Denoise with DADA2
qiime dada2 denoise-single \
  --i-demultiplexed-seqs I_rbcl_output/I_imported_rbcl.qza \
  --p-trunc-len 0 \
  --p-trunc-q 20 \
  --p-max-ee 2 \
  --p-chimera-method pooled \
  --p-n-threads 4 \
  --o-table I_rbcl_output/I_rbcl_filtered_table.qza \
  --o-representative-sequences I_rbcl_output/I_rbcl_filtered_rep_seqs.qza \
  --o-denoising-stats I_rbcl_output/I_rbcl_stats.qza
loading_message "🧬 Processed I_rbcl sequences with DADA2 denoising"

# Export denoising stats to TSV (needed for read count summary)
qiime tools export \
  --input-path I_rbcl_output/I_rbcl_stats.qza \
  --output-path I_rbcl_output/I_rbcl_exported_stats

# Summarize read counts from denoising stats
read_summary=$(awk -F'\t' 'NR==2 {next} NR>1 {input+=$2; filtered+=$3; non_chimeric+=$7} END {printf "📊 Denoising Summary:\n - Total Input Reads: %d\n - Total Filtered Reads: %d\n - Total Non-Chimeric Reads: %d\n", input, filtered, non_chimeric}' I_rbcl_output/I_rbcl_exported_stats/stats.tsv)
loading_message "$read_summary"

# Visualize denoising stats
qiime metadata tabulate \
  --m-input-file I_rbcl_output/I_rbcl_stats.qza \
  --o-visualization I_rbcl_output/I_rbcl_stats.qzv
loading_message "📊 Generated visualization of I_rbcl denoising statistics"

# Summarize feature table
qiime feature-table summarize \
  --i-table I_rbcl_output/I_rbcl_filtered_table.qza \
  --o-visualization I_rbcl_output/I_rbcl_filtered_table.qzv
loading_message "📊 Summarized I_rbcl feature table"

# Export feature table
qiime tools export \
  --input-path I_rbcl_output/I_rbcl_filtered_table.qza \
  --output-path I_rbcl_output/I_rbcl_exported_table
loading_message "📦 Exported I_rbcl feature table"

# Convert to TSV
biom convert \
  -i I_rbcl_output/I_rbcl_exported_table/feature-table.biom \
  --to-tsv
loading_message "📑 Converted I_rbcl feature table to TSV format"

# Export representative sequences
qiime tools export \
  --input-path I_rbcl_output/I_rbcl_filtered_rep_seqs.qza \
  --output-path I_rbcl_output/I_rbcl_fasta_exported
loading_message "🧬 Exported I_rbcl representative sequences"

# Rename FASTA
mv I_rbcl_output/I_rbcl_fasta_exported/dna-sequences.fasta I_rbcl_output/I_rbcl_fasta_exported/dada2_I_rbcl.fasta
loading_message "📛 Renamed I_rbcl FASTA file to dada2_I_rbcl.fasta"

echo -e "\n✅ I_rbcl pipeline completed successfully"