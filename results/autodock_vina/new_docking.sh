#!/bin/bash

# Ligand file
LIGAND="ligand.pdbqt"  # adjust path if needed

# Exhaustiveness
EXHAUST=32

# Output folder
mkdir -p vina_out

# Loop over all receptor directories
for RECEPTOR_DIR in *_receptor; do
    # Skip if not a directory
    [ -d "$RECEPTOR_DIR" ] || continue
    
    echo "Processing $RECEPTOR_DIR..."
    
    # Get base protein name (remove _receptor suffix)
    PROTEIN_NAME="${RECEPTOR_DIR%_receptor}"
    
    # Loop over all .pdbqt files in the receptor directory (these are the receptors)
    for RECEPTOR_FILE in "$RECEPTOR_DIR"/*.pdbqt; do
        # Skip if no files found
        [ -f "$RECEPTOR_FILE" ] || continue
        
        # Extract pocket number from filename
        # Example: GCE50103.1_pocket1.pdbqt -> pocket1
        POCKET_NAME=$(basename "$RECEPTOR_FILE" .pdbqt)
        POCKET_NUM=$(echo "$POCKET_NAME" | grep -o 'pocket[0-9]*')
        POCKET_NUM_ONLY=$(echo "$POCKET_NUM" | sed 's/pocket//')
        
        echo "  Docking to $POCKET_NUM..."
        
        # Find corresponding box.txt file (same base name but .box.txt)
        BOX_FILE="${RECEPTOR_DIR}/${POCKET_NAME}.box.txt"
        
        if [ ! -f "$BOX_FILE" ]; then
            echo "  Warning: No box file for $POCKET_NAME, skipping."
            continue
        fi
        
        # Output files
        OUT_FILE="vina_out/${PROTEIN_NAME}_${POCKET_NUM}_out.pdbqt"
        LOG_FILE="vina_out/${PROTEIN_NAME}_${POCKET_NUM}.log"
        
        # Run Vina
        echo "  Docking $LIGAND -> ${PROTEIN_NAME} ${POCKET_NUM}..."
        vina --receptor "$RECEPTOR_FILE" \
             --ligand "$LIGAND" \
             --config "$BOX_FILE" \
             --exhaustiveness $EXHAUST \
             --out "$OUT_FILE" > "$LOG_FILE"
        
        if [ $? -eq 0 ]; then
            echo "    Docking Done → $OUT_FILE"
        else
            echo "    Docking Failed for ${PROTEIN_NAME} ${POCKET_NUM}"
        fi
    done
done

echo "All docking runs completed!"