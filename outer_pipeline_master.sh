#!/bin/bash
# Purpose: Submit and coordinate the outer cross-validation folds.
#SBATCH --job-name=outer_cv        # outer CV
#SBATCH --array=1-5                # folds 1…5. Change if you change the outer CV folds.
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:10:00

hn=$(hostname -f 2>/dev/null || hostname)
if [[ "${SERVER:-}" == "marvin" || "$hn" == *marvin* || "$hn" == *hpc.uni-bonn.de* ]]; then
  echo "ERROR: outer_pipeline_master.sh is a legacy Spartan-only launcher and bypasses Marvin safety throttles." >&2
  echo "Use run.sh with RUN_PROFILE=... on Marvin." >&2
  exit 2
fi

module load Apptainer
cd path/to/multiclust

# Apptainer image with all dependencies
export SIF=multiview_env.sif 
# Import data
#export INPUT_CSV="synthetic_multimodal_spartan.csv" #For synthetic data in testing
export INPUT_CSV="cleaned_discovery_data.csv" #actual data
#export META_CSV="synthetic_multimodal_spartan_meta.csv" #For synthetic data in testing
export META_CSV="merged_meta.csv" #Actual data

####### Pipeline parameters ########

# Number of outer CV folds
export N_FOLDS=5 
# Threshold for removing columns with too many missing values
export COL_THRESHOLD=0.5 
# Threshold for removing rows with too many missing values
export ROW_THRESHOLD=0.5 
# Threshold for when to log-transform a variable based on its skewness
export SKEW_THRESHOLD=0.75 
# Type of scaler to use: "standard", "minmax", "robust"
export SCALER_TYPE="robust" 
# Actual modalities in the data
export MODALITIES="Internalising Functioning Detachment Psychoticism Cognition" 
#export MODALITIES="m1 m2 m3 m4" # For synthetic test
# Selection of dimensionality reduction method:urrently supported: None, VAE, PCA
export DIMREDUCTION="VAE" 
# Hidden layer dimensions to try in VAE
export HIDDEN_DIMS="100 250 500 1000" 
# Activation functions to try in VAE
export ACTIVATION_FUNCTIONS="LeakyReLU selu swish" 
# Learning rates to try in VAE
export LEARNING_RATES="0.001 0.0001" 
# Batch sizes to try in VAE
export BATCH_SIZES="32 64 128" 
# Latent dimensions to try in VAE
export LATENT_DIMS="2 5 10 20" 
# Optimisation objective: "single" or "multi" (multi-objective). Multi = optimising both cluster quality and stability for each modality and final clusters.
export OPTIMISATION="multi" 
# Number of hyperparameter combinations in each generation
export N_POPULATION=100 
#Number of GA generations
export N_GENERATIONS=10 
# Minimum number of clusters tested (for both individual modalities and final clusters)
export K_MIN=2 
# Maximum number of clusters tested (for both individual modalities and final clusters)
export K_MAX=10 
# Number of bootstraps per generation in which stability is tested
export N_BOOTSTRAP=100 
# Bootstrap modes. Options: 'bootstrap' (with replacement) or 'subsample' (without replacement).
export BOOTSTRAP_MODE='subsample' 
# Maximum number of concurrent bootstrap jobs running on spartan
export MAX_CONCURRENT=1000
# Whether to run SVM classification on the final clustering labels in OUTER mode (TRUE/FALSE)
export DO_SVM="FALSE" 
# Whether to use a hybrid selection of the pareto front. With Hybrid=TRUE it will select the best individuals based individually for each clustering (based on quality alone!)
export ASSEMBLE_HYBRID="FALSE" 
# Whether to enforce a minimum cluster size of 10 in the final clustering step.
export MINCLUSTER=True 
# Set to "TRUE" for testing mode (tests against true labels); "FALSE" for full run
export TEST="FALSE" 
#Crossover rate in GA
export GA_CXPB=0.7 
#Mutation rate in GA
export GA_MUTPB=0.3 
#Number of elite individuals to keep in next generation in GA.
export GA_ELITISM=2 

TEST_phase=0 # Set to 0 for full run or no testing


OUTER_FOLD=${SLURM_ARRAY_TASK_ID}

# Convert to zero-based fold index for Python
FOLD_INDEX=$((OUTER_FOLD - 1))
export FOLD_INDEX


# Ensure we’ve created the initial GA population
N_POPULATION=${N_POPULATION}
K_MIN=${K_MIN}
K_MAX=${K_MAX}
MODALITIES=${MODALITIES}

########################################
# --- Test phases that do not need full pipeline ---
# Expect: TEST is "TRUE" or "FALSE"; TEST_phase is 0..4
if [[ "$TEST" == "TRUE" ]]; then
  case "$TEST_phase" in
    1)
      echo "=== Test phase 1: only running single method (KMeans) ==="
      apptainer exec "$SIF" python full_pipeline.py --mode test1 \
          --input_csv          "${INPUT_CSV}" \
          --meta_csv           "${META_CSV}" \
          --fold_index         "${FOLD_INDEX}" \
          --n_folds            "${N_FOLDS}" \
          --col_threshold      "${COL_THRESHOLD}" \
          --row_threshold      "${ROW_THRESHOLD}" \
          --skew_threshold     "${SKEW_THRESHOLD}" \
          --scaler_type        "${SCALER_TYPE}" \
          --modalities         ${MODALITIES} \
          --TEST               "${TEST}" 
      exit 0
      ;;
    2)
      echo "=== Test phase 2: only running single method (Spectral) ==="
      apptainer exec "$SIF" python full_pipeline.py --mode test2 \
          --input_csv          "${INPUT_CSV}" \
          --meta_csv           "${META_CSV}" \
          --fold_index         "${FOLD_INDEX}" \
          --n_folds            "${N_FOLDS}" \
          --col_threshold      "${COL_THRESHOLD}" \
          --row_threshold      "${ROW_THRESHOLD}" \
          --skew_threshold     "${SKEW_THRESHOLD}" \
          --scaler_type        "${SCALER_TYPE}" \
          --modalities         ${MODALITIES} \
          --TEST               "${TEST}" 
      exit 0
      ;;
    3)
      echo "=== Test phase 3: Verify fusion matrices and individual ensemble cluster ==="
      apptainer exec "$SIF" python full_pipeline.py --mode test3 \
          --input_csv          "${INPUT_CSV}" \
          --meta_csv           "${META_CSV}" \
          --fold_index         "${FOLD_INDEX}" \
          --n_folds            "${N_FOLDS}" \
          --col_threshold      "${COL_THRESHOLD}" \
          --row_threshold      "${ROW_THRESHOLD}" \
          --skew_threshold     "${SKEW_THRESHOLD}" \
          --scaler_type        "${SCALER_TYPE}" \
          --modalities         ${MODALITIES} \
          --TEST               "${TEST}" 
      exit 0
      ;;
    4)
      echo "=== Test phase 4: Final clustering correctness on fusion matrix ==="
      apptainer exec "$SIF" python full_pipeline.py --mode test4 \
          --input_csv          "${INPUT_CSV}" \
          --meta_csv           "${META_CSV}" \
          --fold_index         "${FOLD_INDEX}" \
          --n_folds            "${N_FOLDS}" \
          --col_threshold      "${COL_THRESHOLD}" \
          --row_threshold      "${ROW_THRESHOLD}" \
          --skew_threshold     "${SKEW_THRESHOLD}" \
          --scaler_type        "${SCALER_TYPE}" \
          --modalities         ${MODALITIES} \
          --TEST               "${TEST}" 
      exit 0
      ;;
  esac
fi


########################################

echo "[Fold ${FOLD_INDEX}] Initializing GA population…"
apptainer exec ${SIF} \
    python full_pipeline.py --mode init \
        --population_file population_init_fold${FOLD_INDEX}.pkl \
        --n_population ${N_POPULATION} \
        --k_min ${K_MIN} --k_max ${K_MAX} \
        --modalities ${MODALITIES} \
        --seed ${OUTER_FOLD} \

# Chain GA generations so each bootstrap waits on the previous gather
prev_gather_id=""

# ————————————————————————————————————————

echo "=== Starting outer fold ${FOLD_INDEX} ==="

# GA settings
N_GENERATION=${N_GENERATIONS}
N_BOOTSTRAPS=${N_BOOTSTRAP}
MAX_CONCURRENT=${MAX_CONCURRENT}

# initial population (you must generate this once, e.g. with a small helper script;
# it should be a pickled list of DEAP Individuals)
POP_INIT=population_init${FOLD_INDEX}.pkl
export POP_INIT


########################################
# 1) Nested‐GA
########################################
for GEN in $(seq 1 $N_GENERATIONS); do
  # Export current generation for child jobs
  export GEN
  echo "[Fold $FOLD_INDEX] Generation $GEN: launching bootstrap array..."
  if [ -z "$prev_gather_id" ]; then
    array_id=$(sbatch --parsable \
      --export=ALL,FOLD_INDEX,GEN,POP_INIT,DIMREDUCTION,MINCLUSTER,N_BOOTSTRAP,BOOTSTRAP_MODE,GA_CXPB,GA_MUTPB,GA_ELITISM \
      --array=1-${N_BOOTSTRAPS}%${MAX_CONCURRENT} \
      bootstrap_generation.sh)
  else
    array_id=$(sbatch --parsable \
      --dependency=afterok:${prev_gather_id} \
      --export=ALL,FOLD_INDEX,GEN,POP_INIT,DIMREDUCTION,MINCLUSTER,N_BOOTSTRAP,GA_CXPB,GA_MUTPB,GA_ELITISM \
      --array=1-${N_BOOTSTRAPS}%${MAX_CONCURRENT} \
      bootstrap_generation.sh)
  fi
  echo "  -> array job ID: $array_id"

  echo "[Fold $FOLD_INDEX] Generation $GEN: launching gather job..."
  gather_id=$(sbatch --parsable \
    --dependency=afterok:${array_id} \
    --export=ALL,FOLD_INDEX,GEN,POP_INIT,DIMREDUCTION,MINCLUSTER,N_BOOTSTRAP,GA_CXPB,GA_MUTPB,GA_ELITISM \
    gather_generation.sh)
  echo "  -> gather job ID: $gather_id"

  prev_gather_id=$gather_id

  # now point to the newly‐evolved population for the next iteration
  POP_IN=intermediates/fold${FOLD_INDEX}/ga/population_fold${FOLD_INDEX}_gen$((GEN+1)).pkl
  export POP_IN
done

########################################
# 2) When generation $N_GENERATIONS finishes, run post‐processing (AE + Parea)
########################################

echo "[Fold $FOLD_INDEX] Scheduling final post‐processing..."
sbatch --dependency=afterok:${gather_id} \
  --export=ALL,FOLD_INDEX,POP_IN,DIMREDUCTION,ASSEMBLE_HYBRID,N_BOOTSTRAP,DO_SVM \
  postprocess_outer.sh

exit 0
