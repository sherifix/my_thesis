#!/bin/bash

# Define the base download directory
BASE_DIR="data/reference_structures_try"
mkdir -p "${BASE_DIR}"


# Create an associative array mapping folder names to PDB IDs
# The keys are the directory names (e.g., gh12), values are the PDB IDs
declare -A STRUCTURES=(
    ["gh12"]="3VGI"
    ["gh44"]="2E4T"
    ["gh45"]="5XBU"
    ["gh48"]="5YJ6"
    ["gh5_1"]="2ZUM"
    ["gh5_2"]="2CKS"
    ["gh5_25"]="7VT8"
    ["gh5_4"]="6MQ4"
    ["gh5_5"]="3QR3"
    ["gh6"]="4B4H"
    ["gh7"]="1CEL"
    ["gh9"]="1UT9"
)

# Loop through each family folder and its corresponding PDB ID
for FAMILY in "${!STRUCTURES[@]}"; do
    PDB_ID="${STRUCTURES[$FAMILY]}"
    # Create the family directory
    mkdir -p "${BASE_DIR}/${FAMILY}"
    
    # Define the output file path
    OUTPUT_FILE="${BASE_DIR}/${FAMILY}/${PDB_ID}.pdb"
    
    echo "Downloading ${PDB_ID} to ${FAMILY} folder..."
    
    # Download the PDB file from the RCSB website
    # The `-f` flag ensures a 'Not Found' error is returned if the file doesn't exist
    curl -f -o "${OUTPUT_FILE}" "https://files.rcsb.org/download/${PDB_ID}.pdb"
    
    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Successfully saved to ${OUTPUT_FILE}"
    else
        echo "Error: Failed to download ${PDB_ID}. Please check if the PDB ID is valid."
    fi
    
    echo "-----------------------------------"
done

echo "All downloads attempted."
