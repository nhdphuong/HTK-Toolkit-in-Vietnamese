#!/bin/sh -v
set -xv

# Adding <s> and </s> to dict
echo "<s>          [] sil" >> txt/dict.txt
echo "</s>         [] sil" >> txt/dict.txt

# 3. Recognizing
# Preparing Data
python script/lowerPrompts.py datasets/test/prompts.txt txt/prompts_test_lm.txt
python script/vietnameseToTelex.py txt/prompts_test_lm.txt txt/prompts_test_lm_telex.txt
perl script/prompts2mlf.pl mlf/testLM_words.mlf txt/prompts_test_lm_telex.txt

# File list
python script/listwavmfc.py datasets/test/ txt/testLM.scp txt/testLM_mfc.scp

# Test MLF
htk/HCopy -C cfg/HCopy.cfg -S txt/testLM.scp

echo "Preparing completed"

