#!/bin/sh -v
set -xv

# Building Language Model
# Database preparation
# Adding train prompts to collection
python script/lowerPrompts.py datasets/train/prompts.txt txt/prompts_test.txt
python script/vietnameseToTelex.py datasets/train/prompts.txt txt/prompts_test.txt
python script/combineCollection.py datasets/collection.txt txt/prompts_test.txt txt/collection.txt

# Prepare grammar
htk/LNewMap -f WFC LMName gram/bigram/empty.wmap
htk/LGPrep -a 100000 -b 200000 -n 2 -d gram/bigram gram/bigram/empty.wmap txt/collection.txt

# Language model generation
htk/LBuild -c 2 0 -c 3 0 gram/bigram/wmap gram/bigram/langmodel gram/bigram/gram.*

# Testing the LM perplexity
htk/LPlex -t gram/bigram/langmodel txt/collection.txt | tee result_model_bi.txt

echo "Training completed"

