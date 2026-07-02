# multiclust-clinical-public

Public code snapshot for the clinical multiclust paper analysis.

This repository contains the paper-specific code needed to run the clinical multiclust profile, generate the baseline/demographic tables, and inspect the downstream analysis notebook. It does not contain restricted study data or generated results.

This is an exported snapshot from a private development repository. The private repository remains the source of truth. See `PUBLIC_SNAPSHOT.md` for the export date, source commit, and exact file list.

## What To Look At First

Start with these files:

1. `run_profiles/clinical_paper.sh` configures the clinical paper run.
2. `run.sh` starts the scheduled pipeline using that profile.
3. `outer_pipeline_master.sh` is the outer-pipeline helper used by this profile.
4. `full_pipeline.py` contains the main multiview clustering workflow.
5. `notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd` prepares baseline and demographic tables.
6. `notebooks/clinical_paper/Clinical_main_work.ipynb` contains downstream checks, figures, summaries, and paper-facing analyses.

## Repository Map

```text
.
├── run_profiles/
│   └── clinical_paper.sh
├── notebooks/
│   └── clinical_paper/
│       ├── Clinical_main_work.ipynb
│       └── PrepareData_demtable_paper1.Rmd
├── table_helpers/
│   ├── Basetable_function.R
│   └── Demographictable_function.R
├── run.sh
├── outer_pipeline_master.sh
├── full_pipeline.py
├── requirements_multiview_env.txt
└── multiview_env.def
```

Other private profiles, notebooks, result folders, data folders, and manuscript files are intentionally excluded.

## Data

You need your own approved copy of the restricted study data. This repository does not include:

- raw study data
- private dictionaries
- generated pipeline outputs
- generated tables
- result folders
- manuscript files

Update paths in `run_profiles/clinical_paper.sh` and `notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd` so they point to your local data and output locations.

## Environment

Use either the Python requirements file or the container definition:

- `requirements_multiview_env.txt`
- `multiview_env.def`

The R Markdown table workflow also needs R packages used by the helper scripts, including `dplyr`, `readr`, `stringr`, `tidyr`, `readxl`, `gtsummary`, `flextable`, and `effectsize`.

## Typical Run Order

Run the clinical multiclust pipeline:

```bash
RUN_PROFILE=clinical_paper bash run.sh
```

Generate baseline and demographic tables:

```bash
Rscript -e "rmarkdown::render('notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd')"
```

Open the notebook after pipeline outputs are available:

```bash
jupyter notebook notebooks/clinical_paper/Clinical_main_work.ipynb
```

## For Maintainers

Do not edit this public snapshot by hand unless it is an emergency. Refresh it from the private source repository:

```bash
cd ../multiclust
bash tools/export_public_repos.sh clinical_paper ../multiclust-clinical-public
```

Then review, commit, and push:

```bash
cd ../multiclust-clinical-public
git diff
git add .
git commit -m "Refresh public snapshot"
git push
```

## Citation

Please cite the associated paper and this code snapshot. If a `CITATION.cff` file is added in a future export, prefer that citation metadata.
