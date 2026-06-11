#!/bin/bash

INPUT_CSV="../pockets_summary.tsv"
BASE_DIR="$(pwd)"  # Store the base directory

# Skip header and loop through each line
tail -n +2 "$INPUT_CSV" | while IFS=$'\t' read -r protein pocket_rank pocket_score center_x center_y center_z size_x size_y size_z residues pocket_trimmed_start_end n_terminal_residues pocket_start_end num_atoms path; do
    # Create main directory for this protein (full path)
    PROT_DIR="${BASE_DIR}/${protein}_receptor"
    mkdir -p "$PROT_DIR"

    # Compose box size and center strings
    BOX_CENTER="$center_x $center_y $center_z"
    BOX_SIZE="$size_x $size_y $size_z"

    echo "Processing ${protein} - Pocket ${pocket_rank}..."

    # Run receptor preparation using full path (no cd needed)
    mk_prepare_receptor.py -i "$path" -o "${PROT_DIR}/${protein}_pocket${pocket_rank}" -p -v \
        --box_size $BOX_SIZE --box_center $BOX_CENTER
done
