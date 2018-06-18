#!/bin/sh -v
set -v

# Recognizer Evaluation
# Step 11 - Recognizing the Test Data
# Evaluation prompts - number only if no prompts
# python script/generatePrompts.py datasets/eval/waves/ datasets/eval/prompts.txt
python script/vietnameseToTelex.py datasets/eval/prompts.txt txt/eval_prompts.txt
perl script/prompts2mlf.pl mlf/eval_words.mlf txt/eval_prompts.txt

# Evaluation file list
python script/listwavmfc.py datasets/eval/waves/ txt/eval.scp txt/eval_mfc.scp

# Evaluation MLF
htk/x64/HCopy -C cfg/HCopy.cfg -S txt/eval.scp

# Recognizing the Test Data
htk/x64/HVite -C cfg/HVite.cfg -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -S txt/eval_mfc.scp -i mlf/eval_recout.mlf -w txt/wdnet.txt txt/srcDict.txt phones/tiedlist

# Format results
htk/x64/HResults -I mlf/eval_words.mlf phones/tiedlist mlf/eval_recout.mlf | tee eval_result.txt

read

