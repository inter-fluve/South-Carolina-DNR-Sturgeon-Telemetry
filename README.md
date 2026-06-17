# South-Carolina-DNR-Sturgeon-Telemetry

## Raw Detection Cleaning
Each river/lake system has its own cleaning script:

Santee River → clean_santee.R

Lakes Marion & Moultrie → clean_lakes.R

Cooper River → clean_cooper.R

Each script:

Reads all raw CSVs in the system folder

Aligns inconsistent column names

Repairs misaligned latitude/longitude

Converts numeric and datetime fields

Joins with harmonized metadata

Outputs a cleaned, standardized CSV

To regenerate any system’s cleaned dataset:

run the cleaning scripts

## Metadata Harmonization
SCDNR periodically issues updated tag metadata files.
The pipeline automatically:

Reads all metadata Excel files in the metadata folder

Ignores Excel temp files (~$)

Aligns columns across versions

Combines them into a single metadata table

Ensures consistent tag information across all rivers

To update metadata:

add new metadata files

## Master Ingest & Analysis
master_ingest.R:

Reads all three cleaned datasets

Harmonizes column types

Collapses duplicate lat/long fields

Adds a river identifier

Produces a unified dataset (DF)

Generates exploratory plots

Creates receiver‑level summaries

To run the full pipeline:

run the master ingest script

## Data Privacy & Security
This repository does not contain:

Raw sturgeon movement data

Telemetry timestamps

Receiver locations

Sensitive biological metadata

All raw data remain stored on Inter‑Fluve’s secure shared drive and are not included in this repository.

If you want a dedicated privacy section:

add a data privacy section

## Use of Generative AI
Portions of the code in this repository were developed with assistance from Microsoft Copilot, consistent with Inter‑Fluve’s internal policies regarding the use of generative AI tools.

No sturgeon movement data, telemetry records, or other sensitive project data were provided to Copilot during development. Only generalized code structure, file paths, and non‑sensitive workflow descriptions were used as prompts.

All AI‑assisted code was reviewed, validated, and approved by Inter‑Fluve staff before implementation, and the final workflow reflects Inter‑Fluve’s technical standards and quality assurance practices.

## How to Re‑Run the Entire Pipeline
Place new raw detection files into their respective folders

Place new metadata Excel files into the metadata folder

Run the three cleaning scripts

Run master_ingest.R

Review outputs in /data/processed/

If you want a step‑by‑step guide:

add a pipeline update section

## Future Improvements
Automated QA/QC reporting

Receiver‑level mapping with sf/leaflet

Automated detection‑per‑tag summaries

Integration with HSI model outputs

