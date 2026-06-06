# Cel_Screening

Pipeline for screening thermostable cellulases from GH family sequences.

## Required external data

### dbCAN HMM database

Download dbCAN HMM file from:
https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-HMMdb-V11.txt

Place it in `dbcan/dbCAN.hmm`:

```bash
mkdir -p dbcan
wget -O dbcan/dbCAN.hmm https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-HMMdb-V11.txt
hmmpress dbcan/dbCAN.hmm


## Ligand Preparation

Before running the pipeline, place your ligand SDF file in:

results/autodock_vina/



The pipeline will automatically convert it to PDBQT format using Meeko.

Example:
- For cellotetraose, download the SDF file from PubChem or PDB
- Save it as `results/autodock_vina/cellotetraose.sdf`


## Environment Setup

### Create all required environments

```bash
# Main pipeline
conda env create -f environments/thesis.yml

# Docking
conda env create -f environments/vina.yml

# SignalP6
conda env create -f environments/signalp6.yml

# ThermoProt
conda env create -f environments/thermoprot.yml

# EpHod (optional)
conda env create -f environments/ephod.yml
