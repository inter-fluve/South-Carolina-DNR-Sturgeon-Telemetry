# South-Carolina-DNR-Sturgeon-Telemetry

Repository containing data ingestion, cleaning, harmonization, and exploratory analysis workflows for South Carolina Department of Natural Resources (SCDNR) Sturgeon acoustic telemetry datasets.

---

## Repository Structure

### Raw Detection Cleaning

Each river/lake system has a dedicated cleaning script:

| System                  | Script           |
| ----------------------- | ---------------- |
| Santee River            | `Santee River Cleaning Script.R` |
| Lakes Marion & Moultrie | `Lakes Cleaning Script.R`  |
| Cooper River            | `Cooper Cleaning Script.R` |

Each cleaning script:

* Reads all raw CSV files within the system folder
* Standardizes inconsistent column names
* Repairs misaligned latitude/longitude fields
* Converts numeric and datetime fields to consistent formats
* Joins detections with harmonized tag metadata
* Exports a cleaned and standardized dataset

To regenerate any system-specific dataset, simply rerun the corresponding cleaning script.

---

## Metadata Harmonization

SCDNR periodically provides updated tag metadata files. The metadata workflow automatically:

* Reads all metadata Excel files located in the `metadata/` directory
* Ignores temporary Excel files (e.g., `~$*.xlsx`)
* Aligns columns across metadata versions
* Combines all metadata into a single harmonized table
* Ensures consistent tag information across all river systems

To update metadata:

1. Add new metadata files to the `metadata/` folder.
2. Rerun the cleaning scripts.

---

## Master Ingest & Analysis

The primary workflow is executed through:

```r
R Script.R
```
Found here: "I:\Shared drives\IFI\Projects_Active\SanteeCooper_FERC_19-04-09\IFI_TASKS\Task_Y_SturgUseofLock\SCDNR-Data-Analysis-Tasks\R Script.R"

This script:

* Reads all cleaned system datasets
* Harmonizes column types across datasets
* Consolidates duplicate latitude/longitude fields
* Adds a river-system identifier
* Produces a unified telemetry dataset (`DF`)
* Generates exploratory visualizations
* Creates receiver-level summary statistics

---

## Pipeline Workflow

1. Place new raw detection files into their respective system folders.
2. Place updated metadata Excel files into the `metadata/` folder.
3. Run:

   * `Santee River Cleaning Script.R`
   * `Lakes Cleaning Script.R`
   * `Cooper Cleaning Script.R`
4. Run:

   * `R Script.R`
5. Review outputs

---

## Data Privacy & Security

This repository does **not** contain:

* Raw sturgeon movement data
* Telemetry timestamps
* Receiver coordinates
* Sensitive biological metadata
* Proprietary client information

All raw telemetry data remain stored on Inter-Fluve's secure internal servers and are intentionally excluded from version control.

---

## Use of Generative AI

Portions of the code in this repository were developed with assistance from Microsoft Copilot, consistent with Inter-Fluve's internal policies regarding the use of generative AI tools.

No sturgeon movement data, telemetry records, receiver locations, or other sensitive project information were provided to Copilot during development. Only generalized code structures, workflow descriptions, and non-sensitive programming questions were used.

All AI-assisted code was reviewed, validated, and approved by Inter-Fluve staff prior to implementation. Final analyses and workflows reflect Inter-Fluve's technical standards, quality assurance procedures, and professional judgment.

---

## Future Improvements

Potential enhancements include:

* Automated QA/QC reporting
* Receiver-level mapping using `sf` and `leaflet`
* Automated detection-per-tag summaries
* Spatial movement visualizations
* Integration with habitat suitability and restoration assessment workflows
* Automated report generation

---

## Contact

For questions regarding workflow implementation or project-specific data access, contact the repository maintainer or Inter-Fluve project manager: Tim Brush, Matt DeAngelo, or Rachel Roday (for legacy code)
