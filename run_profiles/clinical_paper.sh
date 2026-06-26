# Clinical multicluster paper profile.
#
# Load with:
#   RUN_PROFILE=clinical_paper sbatch run.sh
#
# This file describes the analysis choices for the paper run. The orchestration
# lives in run.sh/full_pipeline.py; this profile only sets dataset paths,
# modality handling, GA/stability search size, and reporting options.

# ------------------------- Input data -------------------------
export INPUT_CSV="cleaned_discovery_data.csv"
export META_CSV="merged_meta.csv"
export NOTEBOOK="notebooks/clinical_paper/Clinical_main_work.ipynb"

# ---------------------- Modalities/features -------------------
# MODALITIES controls both preprocessing splits and the view order used by the
# genetic algorithm. Keep this order stable when comparing outputs across runs.
export MODALITIES="Internalising Functioning Detachment Psychoticism Cognition"
export DUMMY_CODE_MODALITIES="Internalising Functioning Detachment Psychoticism"
export MIXED_CATEGORICAL_MODALITIES=""

# Dimensionality reduction is applied after preprocessing and before PAREA.
# Empty DIM_REDUCTION_BY_MODALITY means every modality uses DIMREDUCTION.
export DIMREDUCTION="PCA"
export DIM_REDUCTION_BY_MODALITY=""
export PCA_VARIANCE_THRESHOLD="0.99"

# -------------------- GA and resampling search ----------------
# The GA optimizes clustering parameters inside each outer fold. Every
# generation is evaluated by N_BOOTSTRAP subsamples before gather evolves the
# next generation.
export N_FOLDS=5
export N_POPULATION=100
export N_GENERATIONS=10
export N_BOOTSTRAP=100
export BOOTSTRAP_MODE="subsample"

# ------------------ Internal ensemble settings ----------------
# Force the paper profile defaults here. run.sh defines generic defaults before
# sourcing profiles, so ${VAR:-...} would otherwise preserve those generic values.
export INTERNAL_ENSEMBLE_ENABLED="TRUE"

# Use the paper-grade internal resampling depth during GA and final merge.
if [ "${ALLOW_PROFILE_INTERNAL_ENSEMBLE_BCS_OVERRIDE:-FALSE}" = "TRUE" ]; then
  export INTERNAL_ENSEMBLE_BCS=${INTERNAL_ENSEMBLE_BCS:-50}
else
  export INTERNAL_ENSEMBLE_BCS=100
fi
export INTERNAL_ENSEMBLE_SAMPLE_FRAC=${INTERNAL_ENSEMBLE_SAMPLE_FRAC:-0.8}
export INTERNAL_ENSEMBLE_FEATURE_FRAC=${INTERNAL_ENSEMBLE_FEATURE_FRAC:-1.0}
if [ "${ALLOW_PROFILE_INTERNAL_ENSEMBLE_BCS_OVERRIDE:-FALSE}" = "TRUE" ]; then
  export FINAL_INTERNAL_ENSEMBLE_BCS=${FINAL_INTERNAL_ENSEMBLE_BCS:-50}
else
export FINAL_INTERNAL_ENSEMBLE_BCS=100
fi

# ---------------- Internal ensemble diagnostics ---------------
# Fixed-k diagnostic for deciding internal ensemble resampling depth.
# Submit with: RUN_PROFILE=clinical_paper bash run_internal_ensemble_sweep.sh
export ENSEMBLE_SWEEP_K_VALUES=${ENSEMBLE_SWEEP_K_VALUES:-"2 3 4 5"}
export ENSEMBLE_SWEEP_BCS=${ENSEMBLE_SWEEP_BCS:-"5 15 30 50 100"}
export ENSEMBLE_SWEEP_OUTER_RESAMPLES=${ENSEMBLE_SWEEP_OUTER_RESAMPLES:-100}
export ENSEMBLE_SWEEP_OUTER_SAMPLE_FRAC=${ENSEMBLE_SWEEP_OUTER_SAMPLE_FRAC:-0.8}
export ENSEMBLE_SWEEP_ARRAY_CONCURRENCY=${ENSEMBLE_SWEEP_ARRAY_CONCURRENCY:-3}
export ENSEMBLE_SWEEP_CPUS=${ENSEMBLE_SWEEP_CPUS:-96}
export ENSEMBLE_SWEEP_JOBS=${ENSEMBLE_SWEEP_JOBS:-${ENSEMBLE_SWEEP_CPUS}}
export ENSEMBLE_SWEEP_MEM=${ENSEMBLE_SWEEP_MEM:-128G}
export ENSEMBLE_SWEEP_TIME=${ENSEMBLE_SWEEP_TIME:-08:00:00}
export ENSEMBLE_SWEEP_OUTPUT_DIR=${ENSEMBLE_SWEEP_OUTPUT_DIR:-"results/internal_ensemble_sweep"}

# --------------------- SLURM packing controls -----------------
# Marvin: keep the grouped Slurm footprint below the 300-job run budget while
# avoiding a full-node CPU request so grouped jobs can start more readily.
export MARVIN_BOOTSTRAPS_PER_JOB=${MARVIN_BOOTSTRAPS_PER_JOB:-25}
export MARVIN_BOOTSTRAP_PARALLEL_STEPS=${MARVIN_BOOTSTRAP_PARALLEL_STEPS:-4}
export MARVIN_BOOTSTRAP_STEP_CPUS=${MARVIN_BOOTSTRAP_STEP_CPUS:-16}
export MARVIN_BOOTSTRAP_JOB_CPUS=${MARVIN_BOOTSTRAP_JOB_CPUS:-$((MARVIN_BOOTSTRAP_PARALLEL_STEPS * MARVIN_BOOTSTRAP_STEP_CPUS))}
export MARVIN_MAX_SUBMITTED_JOBS=${MARVIN_MAX_SUBMITTED_JOBS:-300}
export MARVIN_SUBMIT_JOB_BUDGET=${MARVIN_SUBMIT_JOB_BUDGET:-300}
export SPARTAN_BOOTSTRAPS_PER_JOB=${SPARTAN_BOOTSTRAPS_PER_JOB:-2}
export SPARTAN_BOOTSTRAP_PARALLEL_STEPS=${SPARTAN_BOOTSTRAP_PARALLEL_STEPS:-1}
export SPARTAN_BOOTSTRAP_STEP_CPUS=${SPARTAN_BOOTSTRAP_STEP_CPUS:-16}
export SPARTAN_SERIALIZE_FOLDS=${SPARTAN_SERIALIZE_FOLDS:-FALSE}
export MAX_CONCURRENT=200

# ---------------------- Final model/reporting -----------------
export MINCLUSTER="TRUE"
export MINCLUSTER_N=50
export MINCLUSTER_RESAMPLE_MODE="fixed"
export USE_EFFECTIVE_K_FOR_FOLD_MERGE="FALSE"
export USE_CROSS_FOLD_EFFECTIVE_K_FOR_FINAL_RUN="FALSE"
export DO_SVM="TRUE"
export RUN_MERGE="TRUE"
export RUN_POSTPROCESS_REPORT="TRUE"

# "outside" estimates final stability on fixed full-data representations.
# Use "inside" when each stability resample should rerun preprocessing and
# dimensionality reduction from raw data.
export FINAL_BOOTSTRAP_PREPROCESSING="outside"

# ---------------------- Cluster validation --------------------
export COMPUTE_CLUSTER_PVALUES="TRUE"
export CLUSTER_PVALUE_MODE="fast"
export CLUSTER_PVALUE_STAT="composite"
export CLUSTER_PVALUE_PERMUTATIONS=1000
export CLUSTER_PVALUE_PERMUTATIONS_QUALITY=1000
export CLUSTER_PVALUE_PERMUTATIONS_ARI=500
export DO_CLUSTER_VALIDATION_SENSITIVITY="TRUE"
export CLUSTER_VALIDATION_JOBS=${CLUSTER_VALIDATION_JOBS:-0}
