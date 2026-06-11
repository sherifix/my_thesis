#!/bin/bash

cd ~/my_thesis/data
mkdir -p proteomes
cd proteomes

while read -r TAXID; do
  [[ -z "$TAXID" || "$TAXID" =~ ^# ]] && continue

  # Try reference genome first, fallback to normal summary
  GCA=$(datasets summary genome taxon "$TAXID" --reference \
        | jq -r 'if .total_count==0 then empty else .reports[0].paired_accession // empty end')
  [[ -z "$GCA" ]] && GCA=$(datasets summary genome taxon "$TAXID" \
        | jq -r '.reports[0].paired_accession // empty')

  [[ -z "$GCA" ]] && continue  # skip if still empty

  datasets download genome accession "$GCA" \
    --assembly-source GenBank --include protein --filename ${TAXID}_${GCA}.zip


done < ~/my_thesis/data/thermobase_data/taxids.txt
