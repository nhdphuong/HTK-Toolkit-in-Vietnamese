#!/bin/sh -v
set -xv

# 3. Recognizing
# Preparing Data
python script/vietnameseToTelex.py datasets/test/prompts.txt txt/testLM_prompts.txt
perl script/prompts2mlf.pl mlf/testLM_words.mlf txt/testLM_prompts.txt

# File list
python script/listwavmfc.py datasets/test/ txt/testLM.scp txt/testLM_mfc.scp

# Test MLF
htk/HCopy -C cfg/HCopy.cfg -S txt/testLM.scp

# Recognizing
htk/HVite -C cfg/HVite.cfg -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -S txt/testLM_mfc.scp -i mlf/eval_recout.mlf -w gram/langmodel txt/srcDict.txt phones/tiedlist

# Format Results
htk/HResults -I mlf/testLM_words.mlf phones/tiedlist mlf/recoutLM.mlf | tee result_lm.txt

