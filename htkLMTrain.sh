#!/bin/sh -v
set -xv

# 1. Training cross-word triphone models
#


# 2. Building Language Model
# Database preparation
htk/LNewMap -f WFC LMName gram/empty.wmap
htk/LGPrep -a 100000 -b 200000 -n 3 -d gram gram/empty.wmap datasets/collection.txt

# Language model generation
htk/LBuild -c 2 0 -c 3 0 gram/wmap gram/langmodel gram/gram.*

# Testing the LM perplexity
htk/LPlex -t gram/langmodel datasets/collection.txt | tee result_model.txt

echo "Training completed"
read
