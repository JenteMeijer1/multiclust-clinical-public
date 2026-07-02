# multiclust-clinical-public

Code release for the clinical multiclust paper analysis.

This repository contains the paper-specific pipeline scripts, notebook code, and table-generation code used for the clinical multiclust analysis.

## Contents

- `run_profiles/clinical_paper.sh`: run configuration for the clinical paper analysis.
- `run.sh`: pipeline entry point.
- `outer_pipeline_master.sh`: outer-pipeline helper used by this profile.
- `full_pipeline.py`: main multiview clustering workflow.
- `notebooks/clinical_paper/Clinical_main_work.ipynb`: downstream analysis notebook for checks, figures, summaries, and paper-facing analyses.
- `notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd`: baseline and demographic table workflow.
- `table_helpers/`: R helper functions used by the table workflow.
- `requirements_multiview_env.txt` and `multiview_env.def`: environment specifications.

## Environment

The Python environment is described in `requirements_multiview_env.txt`. A container definition is provided in `multiview_env.def`. The R table workflow also requires packages used by the helper scripts, including `dplyr`, `readr`, `stringr`, `tidyr`, `readxl`, `gtsummary`, `flextable`, and `effectsize`.

## Running

Pipeline:

```bash
RUN_PROFILE=clinical_paper bash run.sh
```

Baseline and demographic tables:

```bash
Rscript -e "rmarkdown::render('notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd')"
```

Notebook:

```bash
jupyter notebook notebooks/clinical_paper/Clinical_main_work.ipynb
```

The notebook assumes that relevant pipeline outputs have already been generated.

## Citation

Please cite the associated paper when using this code.
