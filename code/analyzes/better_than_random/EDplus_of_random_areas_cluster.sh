#!/bin/bash
#SBATCH -J randomEDplus
#SBATCH --nodes=1
#SBATCH --ntasks 1
#SBATCH --partition=skylake-96
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --mem=16G
#SBATCH --mail-type=END

# go to working directory
cd /scratch/utr_gronefeld/Minimize_KBAs

# load environment
source ~/.bashrc
mamba activate R

# run code
Rscript code/analyzes/better_than_random/EDplus_of_random_areas_cluster.R

# deactivate environment
mamba deactivate

