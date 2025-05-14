import os
import glob

# Define the directory containing the FASTQ files
directory = "C:/University/2025/kyle_research_project/Data_processing/Seq_data/master_F_rbcl/trimmed_rbcl"

# Define the output manifest file paths
impala_manifest_file = "C:/University/2025/kyle_research_project/Data_processing/Seq_data/master_F_rbcl/trimmed_rbcl/impala_manifest_rbcl.tsv"
elephant_manifest_file = "C:/University/2025/kyle_research_project/Data_processing/Seq_data/master_F_rbcl/trimmed_rbcl/elephant_manifest_rbcl.tsv"

# Define sample IDs for each group
impala_samples = [f"{i}-rbcl" for i in range(25, 49)] + ["C1-rbcl"]
elephant_samples = [f"{i}-rbcl" for i in range(49, 73)] + ["C3-rbcl"]

# Convert expected sample IDs to lowercase for case-insensitive comparison
impala_samples_lower = [s.lower() for s in impala_samples]
elephant_samples_lower = [s.lower() for s in elephant_samples]

# Debug: Print the directory being searched
print(f"Searching for .fastq.gz files in: {directory}")

# Get a list of all .fastq.gz files in the directory (exclude .cutadapt.log files)
fastq_files = glob.glob(os.path.join(directory, "*.fastq.gz"))

# Debug: Print the number of files found and their names
print(f"Found {len(fastq_files)} .fastq.gz files:")
for f in fastq_files:
    print(f" - {os.path.basename(f)}")

# Function to convert Windows path to Linux (WSL) path
def to_linux_path(windows_path):
    # Convert to absolute path
    abs_path = os.path.abspath(windows_path)
    # Replace 'C:\' with '/mnt/c/' and convert backslashes to forward slashes
    if abs_path.startswith("C:\\"):
        linux_path = abs_path.replace("C:\\", "/mnt/c/").replace("\\", "/")
    else:
        # If not on C: drive, just replace backslashes
        linux_path = abs_path.replace("\\", "/")
    return linux_path

# Function to write manifest file with Unix line endings and Linux paths
def write_manifest(file_path, sample_ids, sample_ids_lower):
    with open(file_path, "w", newline="\n") as f:
        # Write the header
        f.write("sample-id\tabsolute-filepath\n")
        
        # Process each FASTQ file
        for file_path in sorted(fastq_files):
            # Extract the file name
            file_name = os.path.basename(file_path)
            
            # Extract the sample ID (e.g., 25-rbcL, C1-rbcL) and strip any whitespace
            sample_id = file_name.split("_")[0].strip()
            sample_id_lower = sample_id.lower()
            
            # Debug: Print the extracted sample ID
            print(f"Extracted sample ID: {sample_id}")
            
            # Check if the sample ID belongs to the specified group (case-insensitive)
            if sample_id_lower in sample_ids_lower:
                # Get the original sample ID for writing (to preserve case in output)
                original_sample_id = sample_ids[sample_ids_lower.index(sample_id_lower)]
                # Convert the absolute path to Linux format
                linux_path = to_linux_path(file_path)
                
                # Write the entry to the manifest file with Unix line ending
                f.write(f"{original_sample_id}\t{linux_path}\n")

# Create the impala manifest
write_manifest(impala_manifest_file, impala_samples, impala_samples_lower)
print(f"Impala manifest file created: {impala_manifest_file}")

# Create the elephant manifest
write_manifest(elephant_manifest_file, elephant_samples, elephant_samples_lower)
print(f"Elephant manifest file created: {elephant_manifest_file}")

# Check for missing samples
all_expected_samples = impala_samples + elephant_samples
all_expected_samples_lower = [s.lower() for s in all_expected_samples]
found_samples = [os.path.basename(f).split("_")[0].strip().lower() for f in fastq_files]
missing_samples = [s for s, s_lower in zip(all_expected_samples, all_expected_samples_lower) if s_lower not in found_samples]
if missing_samples:
    print("Warning: The following expected samples were not found in the directory:")
    for sample in missing_samples:
        print(f" - {sample}")
else:
    print("All expected samples were found.")