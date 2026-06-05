#!/bin/bash
set -e

# Split sequences into eukaryotic and prokaryotic
python scripts/split_euk_pro.py

# Initialize conda for bash
source /home/ubuntu/miniconda3/etc/profile.d/conda.sh

conda activate signalp6

FASTA_DIR="data/fasta_files"
OUT_BASE="results/signalp"
MODELS="$HOME/tools/signalp/signalp6_slow_sequential/signalp-6-package/models"

mkdir -p "$OUT_BASE"

for group in pro euk; do
    if [[ "$group" == "pro" ]]; then
        fasta="$FASTA_DIR/prokaryotic.faa"
        organism="other"
        outdir="$OUT_BASE/pro"
    else
        fasta="$FASTA_DIR/eukaryotic.faa"
        organism="euk"
        outdir="$OUT_BASE/euk"
    fi

    mkdir -p "$outdir"

    if [[ -f "$fasta" && -s "$fasta" ]]; then
        echo "Running SignalP6 for $group ..."
        signalp6 \
            --fastafile "$fasta" \
            --organism "$organism" \
            --output_dir "$outdir" \
            --format txt \
            --mode slow-sequential \
            --model_dir "$MODELS"
    else
        echo "Warning: $fasta is empty or missing, skipping $group"
    fi
done

conda deactivate
echo "SignalP prediction complete!"
