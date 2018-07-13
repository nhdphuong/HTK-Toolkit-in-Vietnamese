#!/bin/sh -v
set -xv

# Recognizer Evaluation
# Step 11 - Recognizing the Test Data
# Evaluation prompts - number only if no prompts
python script/generatePrompts.py datasets/eval/waves/ datasets/eval/prompts.txt
python script/vietnameseToTelexPrompts.py datasets/eval/prompts.txt txt/eval_prompts.txt
perl script/prompts2mlf.pl mlf/eval_words.mlf txt/eval_prompts.txt

# Evaluation file list
python script/listwavmfc.py datasets/eval/waves/ txt/eval.scp txt/eval_mfc.scp

# Evaluation MLF
htk/HCopy -C cfg/HCopy.cfg -S txt/eval.scp


