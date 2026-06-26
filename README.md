# clinical-paper-public

This repository is a public, paper-specific snapshot for the clinical multiclust paper profile.

The private development repository remains the source of truth. This public repository may lag behind ongoing private development; see `PUBLIC_SNAPSHOT.md` for the export date, source commit, selected profile, and allowlist.

## Included Workflow

- Profile: `run_profiles/clinical_paper.sh`
- Main analysis notebook: `notebooks/clinical_paper/Clinical_main_work.ipynb`
- Baseline and demographic tables: `notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd`
- Main pipeline entry point: `run.sh`
- Outer pipeline helper: `outer_pipeline_master.sh`

## Data

This snapshot contains code only. Real study data, derived private result files, and local output folders are not included. To run the workflow, provide the required study data in the locations configured by `run_profiles/clinical_paper.sh`, or adapt that profile for your environment.

## Running

Install the Python/R environment from `requirements_multiview_env.txt` or build the Apptainer/Singularity image from `multiview_env.def`.

```bash
RUN_PROFILE=clinical_paper bash run.sh
```

Run the notebook after pipeline outputs are available:

```bash
jupyter notebook notebooks/clinical_paper/Clinical_main_work.ipynb
```

Generate baseline and demographic tables with:

```bash
Rscript -e "rmarkdown::render('notebooks/clinical_paper/PrepareData_demtable_paper1.Rmd')"
```

## Citation

Please cite the associated paper and this code snapshot. If a `CITATION.cff` file is added in a future export, prefer that citation metadata.
