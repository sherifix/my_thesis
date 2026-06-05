import pandas as pd
import re
import subprocess
from Bio import SeqIO
import os
from pathlib import Path

# Get current working directory (snakefile location)
BASE_DIR = os.getcwd()

# Define paths relative to BASE_DIR
input_csv = os.path.join(BASE_DIR, "results/raw_results_hmmsearch.csv")
output_dir = os.path.join(BASE_DIR, "output_files")
fasta_output_dir = os.path.join(BASE_DIR, "data/fasta_files")

os.makedirs(output_dir, exist_ok=True)
os.makedirs(fasta_output_dir, exist_ok=True)

# Read the CSV
df = pd.read_csv(input_csv)
df["evalue"] = pd.to_numeric(df["evalue"])

# Filter candidates with overlapping domains
coords = df["domain_coord"].astype(str).str.extract(r"(\d+):(\d+)")
df["start"] = coords[0].astype(int)
df["end"] = coords[1].astype(int)

df = df.sort_values(["accession", "evalue"], ascending=[True, True])

kept_rows = []
for acc, sub in df.groupby("accession", sort=False):
    sub = sub.sort_values("evalue", ascending=True)
    selected = []
    for _, row in sub.iterrows():
        overlap = False
        for s in selected:
            if not (row["end"] < s["start"] or row["start"] > s["end"]):
                overlap = True
                break
        if not overlap:
            selected.append(row)
    kept_rows.extend(selected)

df_filtered = pd.DataFrame(kept_rows).drop(columns=["start", "end"])


#keep only domain length > 100 aa
df_filtered = df_filtered[df_filtered['domain_len'] > 100]


# Get domain for entries (bacteria, archaea, eukaryote)
def get_domain(taxid):
    try:
        cmd = subprocess.run(
            f'efetch -db taxonomy -id {taxid} -mode xml | xtract -pattern LineageEx -block Taxon -if Rank -equals domain -element ScientificName',
            shell=True, capture_output=True, text=True, check=True
        )
        return cmd.stdout.strip()
    except:
        return "unknown"

# Get domain for only unique taxIDs
if "taxID" in df_filtered.columns:
    taxids = df_filtered["taxID"].dropna().tolist()
    unique_taxids = set(taxids)

    domain_mapping = {}
    for taxid in unique_taxids:
        domain_mapping[str(int(float(taxid)))] = get_domain(int(float(taxid)))
    df_filtered["domain"] = df_filtered["taxID"].astype(str).map(domain_mapping)

# Save filtered CSV
output_csv = os.path.join(output_dir, "filtered_hmmsearch_results.csv")
df_filtered.to_csv(output_csv, index=False)
print(f"Saved filtered results to {output_csv}")

# Prepare fasta file with sequences of the filtered accessions
accessions = set(df_filtered["accession"].tolist())

output_fasta = os.path.join(fasta_output_dir, "filtered_hmmsearch.faa")

# Look for proteome files in data/proteomes (both .faa and .fasta)
proteomes_dir = os.path.join(BASE_DIR, "data/proteomes")
if os.path.exists(proteomes_dir):
    with open(output_fasta, "w") as f:
        # Find both .faa and .fasta files
        for ext in ["*.faa", "*.fasta"]:
            for fasta_file in Path(proteomes_dir).rglob(ext):
                print(f"Scanning {fasta_file.name}...")
                for record in SeqIO.parse(fasta_file, "fasta"):
                    if record.id in accessions:
                        SeqIO.write(record, f, "fasta")

    print(f"Extracted sequences to {output_fasta}")
else:
    print(f"Warning: {proteomes_dir} not found. Skipping FASTA extraction.")
