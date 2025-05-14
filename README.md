# DADA2_Pipeline_metabarcoding
Bash scripts for denoising DNA trnl and rbcl sequence metabarcoding data for herbavore dietary analysis
## Prerequisites for these bash scripts to run:

- Need to run it in the WSL using a environment called `qiime2-amplicon-2024.10` with dada2 and qiime2 installed.
- Need to set WD to the directory that holds your specific manifest files.
- Depending on the particular script you are running, you need to name your manifest TSV files exactly the same as mine and also make sure they are have unix format file paths:
- `elephant_manifest_rbcl.tsv`
- `elephant_manifest_trnl.tsv`
- `impala_manifest_rbcl.tsv`
- `impala_manifest_trnl.tsv`
- All output directories from these scripts will be saved within your WD
