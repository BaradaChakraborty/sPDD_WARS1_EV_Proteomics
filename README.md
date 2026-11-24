# sPDD WARS1 EV Proteomics Audit

## Objective
This repository evaluates whether Wars1 (tryptophanyl-tRNA synthetase 1, UniProt P32921) is statistically enriched alongside Rps3 (UniProt P62908) in neuronal extracellular vesicle proteomics from Ifnb-deficient mice (PRIDE accession PXD038362, Tresse et al., 2023, Molecular Psychiatry).

## Repository Structure
- `data/raw/`: Local storage for downloaded PRIDE or supplementary proteomics files (ignored by Git).
- `data/processed/`: Cleaned protein intensity tables.
- `scripts/`: Numbered modular R scripts for data retrieval, filtering, and statistical testing.
- `results/tables/`: Exported file manifests and differential abundance statistics.
- `results/figures/`: Quality control and volcano plots.

## Reproducibility
All R package dependencies are locked with `renv`. Run `renv::restore()` before executing the scripts in numerical order.