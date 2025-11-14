#!/bin/bash
#SBATCH -J 75boots
#SBATCH --nodes=1
#SBATCH --ntasks 1
#SBATCH --partition=skylake-96
#SBATCH --cpus-per-task=16
#SBATCH --time=12-00:00:00
#SBATCH --mem=24G
#SBATCH --mail-type=END

# go to working directory
cd /scratch/utr_gronefeld/Minimize_KBAs

# load environment
source ~/.bashrc
mamba activate R

# run code
Rscript code/analyzes/optimize_bootstraps/75/find_best_KBA_combination.R

# deactivate environment
mamba deactivate