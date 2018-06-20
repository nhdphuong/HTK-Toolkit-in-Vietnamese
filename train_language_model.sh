#!/bin/sh -v
set -xv

# Building Language Model
# Database preparation
# Adding train prompts to collection
python script/vietnameseToTelex.py datasets/train/prompts.txt txt/prompts_test.txt
python script/combineCollection.py datasets/collection.txt txt/prompts_test.txt txt/collection.txt

# Prepare grammar
htk/LNewMap -f WFC LMName gram/empty.wmap
htk/LGPrep -a 100000 -b 200000 -n 3 -d gram gram/empty.wmap txt/collection.txt

# Language model generation
htk/LBuild -c 2 0 -c 3 0 gram/wmap gram/langmodel gram/gram.*

# Testing the LM perplexity
htk/LPlex -t gram/langmodel txt/collection.txt | tee result_model.txt

echo "Training completed"

