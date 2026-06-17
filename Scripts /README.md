## Cleaning Scripts (`scripts/`)

These scripts process raw CSV detection files for each river and lake system. Each script:

* Reads all raw detection files within the system folder
* Standardizes inconsistent column names
* Repairs misaligned latitude and longitude fields
* Converts numeric and datetime fields to consistent formats
* Joins detections with harmonized metadata
* Outputs a cleaned, standardized dataset

### Included Scripts

| Script                  | Description                                                                                           |
| ----------------------- | ----------------------------------------------------------------------------------------------------- |
| `Santee River Cleaning Scirpt.R`        | Cleans Santee River detections                                                                        |
| `Lakes Cleaning Script.R`         | Cleans Lakes Marion & Moultrie detections                                                             |
| `Cooper Cleaning Scirpt .R`        | Cleans Cooper River detections                                                                        |
| `R Script.R` | Reads all metadata Excel files, aligns columns across versions, and produces a unified metadata table |

Run these scripts whenever new raw detection files or metadata files are added.

---

## Master Ingest Script

### `R Script.R`

This script combines all cleaned datasets into a single unified dataframe and performs initial exploratory analyses.

The script:

* Reads cleaned Santee, Lakes, and Cooper datasets
* Harmonizes column types across systems
* Consolidates duplicate latitude and longitude fields
* Adds a river-system identifier
* Produces a unified dataset (`DF`)
* Generates exploratory plots
* Creates receiver-level summaries

Run this script after all cleaning scripts have been completed.

---

## Workflow

1. Place new raw detection files into their respective system folders.
2. Place updated metadata Excel files into the `metadata/` folder.
3. Run all cleaning scripts in `scripts/`.
4. Run `R Script.R`.
5. Review outputs in the processed data directory.

---

## AI Assistance Disclosure

Portions of these scripts were developed with assistance from Microsoft Copilot, consistent with Inter-Fluve's internal policies regarding the use of generative AI tools.

No sturgeon movement data, telemetry records, receiver locations, or other sensitive project information were provided to Copilot during development.

All AI-assisted code was reviewed, validated, and approved by Inter-Fluve staff prior to implementation.

---

