#!/bin/bash
#SBATCH -J 200boots
#SBATCH --nodes=1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-64%24
#SBATCH --partition=skylake-96
#SBATCH --time=14-00:00:00
#SBATCH --mem=8G
#SBATCH --mail-type=END

# go to working directory
cd /scratch/utr_gronefeld/Minimize_KBAs

# load environment
source ~/.bashrc
mamba activate R

# run code
Rscript code/analyzes/optimize_bootstraps/200/find_best_KBA_combination.R $SLURM_ARRAY_TASK_ID

# deactivate environment
mamba deactivate
