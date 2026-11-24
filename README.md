# sPDD WARS1 EV Proteomics Audit

## Overview

This repository investigates whether Tryptophanyl tRNA Synthetase 1 (WARS1) is present and enriched in neuronal extracellular vesicles (EVs) from Ifnb-/- versus wild type (WT) mice in Tresse et al. (2023), Molecular Psychiatry (doi:10.1038/s41380-023-02251-4; PMC10914608; PRIDE PXD038362), alongside microglial WARS expression in Westfall et al. (2022), Acta Neuropathologica Communications (doi:10.1186/s40478-022-01472-y; PMC9677917), to support doctoral research planning on neuroinflammation and sporadic Parkinsons disease with dementia (sPDD).

## Key Findings from Tresse et al. (2023) Supplementary Data

- Source audited: Official Springer supplementary PDF (41380_2023_2251_MOESM1_ESM.pdf, 24.0 MB) downloaded into data/raw/ after an ~8.9 GB .pdResult download from PRIDE stalled and was stopped early.
- Target table located: Supplementary table 1: List of TLR modulators (activator and inhibitor proteins) in the supplementary PDF, not Supplementary Table 11.
- WARS1 enrichment in KO vs WT: Tryptophanyl tRNA Synthetase 1 (Symbol: WARS1, UniProt ID: E0CXX4) is annotated under target TLR2, TLR4 with KO vs WT log2 Fold-change = 4.17236, KO vs WT p-value = 0.005211, and Rank = 100.
- Comparison with Rps3: Ribosomal protein S3 (Rps3, P62908) appears below WARS1 in the same table under target TLR4 with KO vs WT log2 Fold-change = 2.67281, KO vs WT p-value = 0.034660, and Rank = 299.
- Sequence check on E0CXX4: Mouse UniProt entry E0CXX4 is 39 amino acids long (MADMPSGESCTSPLELFNSIATQGELVRSLKAGNAPKDC). Its first 37 amino acids match residues 1 to 37 of canonical mouse WARS1 (P32921, MADMPSGESCTSPLELFNSIATQGELVRSLKAGNAPKDEIDSAVKML) within the N-terminal WHEP signaling region, while the final two residues (DC vs DE) differ.

## Key Findings from Westfall et al. (2022) Supplementary Tables

- Microglial subcluster enrichment (MOESM14, Supplementary Table 3): WARS is enriched in microglial Cluster 3 (inflammatory and nodule-associated subcluster) with Avg Log2 FC = 0.84574593392101505 and Adjusted p-value = 3.2698802413494899E-77.
- Disease contrast in microglia (MOESM13, Supplementary Table 2, RE vs FCD): WARS is higher in Rasmussen encephalitis (RE) versus focal cortical dysplasia (FCD) microglia with Log2 Fold Change = 2.6086154364033498 and Adjusted p-value = 1.07245659623292E-5.
- Scope note: Westfall et al. (2022) analyzed human pediatric RE, FCD, and control snRNA-seq and spatial proteomics data rather than sPDD or extracellular vesicle secretion, so these results support microglial WARS association with inflammatory states rather than direct sPDD EV causation.

## Assuming why Tresse et al. (2023) Pursued Rps3 Over WARS1

Although WARS1 shows a higher KO vs WT log2 fold-change (4.17236 vs 2.67281), a lower p-value (0.005211 vs 0.034660), and a higher rank (100 vs 299) than Rps3 in the TLR modulators table, Tresse et al. (2023) centered their study on mitochondrial DNA damage, oxidized DNA binding, and TLR4-mediated spread. Rps3 connects DNA binding and mitochondrial maintenance directly to TLR4, whereas WARS1 is an aminoacyl tRNA synthetase rather than a canonical DNA-binding factor. Combined with WARS enrichment in inflammatory microglial Cluster 3 in Westfall et al. (2022), WARS1-driven TLR2 and TLR4 signaling alongside damaged mtDNA and Rps3 remains a distinct, testable question for future neuroinflammation research.

## Repository Structure

- scripts/01_fetch_pxd038362_manifest.R : Queries PRIDE API for PXD038362 file metadata and writes results/tables/pxd038362_file_manifest.csv.
- scripts/02_check_supp_table11_wars1_rps3.R : Downloads and parses 41380_2023_2251_MOESM1_ESM.pdf, searches for target hits, inspects E0CXX4 against P32921, and exports table outputs.
- scripts/03_check_westfall2022_wars.R : Fetches Westfall et al. (2022) supplementary Excel files and audits WARS across microglial DEGs and subclusters.
- results/tables/ : Saved CSV and TXT outputs from R scripts and console inspections.
- renv.lock and renv/ : Reproducible R package environment lockfile and library setup.