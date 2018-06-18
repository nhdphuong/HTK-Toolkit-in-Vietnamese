#!/bin/sh -v
set -v

# 1. Training cross-word triphone models
#


# 2. Building Language Model
# Database preparation
htk/x64/LNewMap -f WFC LMName gram/empty.wmap
htk/x64/LGPrep -a 100000 -b 200000 -n 3 -d gram gram/empty.wmap train/collection.txt

# Language model generation
htk/x64/LBuild -c 2 0 -c 3 0 gram/wmap gram/langmodel gram/gram.*

# Testing the LM perplexity
htk/x64/LPlex -t gram/langmodel test/collection.txt

# 3. Recognizing
# Preparing Data
python script/vietnameseToTelex.py test1/prompts.txt txt/testLM_prompts.txt
perl script/prompts2mlf.pl mlf/testLM_words.mlf txt/testLM_prompts.txt

# File list
python script/listwavmfc.py c:/Active/WorkingProjects/anotherHTK/test1/ txt/testLM.scp txt/testLM_mfc.scp

# Recognizing
htk/x64/HDecode -H htmm/hmm15/macros -H htmm/hmm15/hmmdefs -S txt/testLM_mfc.scp -t 220.0 220.0 -C cfg/config.hdecode -i mlf/recoutLM.mlf -w gram/langmodel -p 0.0 -s 5.0 txt/dict.txt phones/tiedlist

# Format Results
htk/x64/HResults -I mlf/test_words.mlf phones/tiedlist mlf/recout.mlf | tee resultLM.txt

echo "Training completed"
read

