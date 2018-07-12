#!/bin/sh -v
set -xv

# Preparing folder for the run
sh script/preparingWorkspace.sh

# Preparing Data
# Step 1 - the Task Grammar
# prompts -> telex lower case
python script/lowerPrompts.py datasets/train/prompts.txt txt/prompts_test.txt
python script/vietnameseToTelex.py txt/prompts_test.txt txt/prompts_test_telex.txt

# prompts -> wlist
perl script/prompts2wlist.pl txt/prompts_test.txt txt/wlist.txt
python script/vietnameseToTelex.py txt/wlist.txt txt/wlist_telex_t.txt
perl script/sort.pl txt/wlist_telex_t.txt txt/wlist_telex.txt

# gram.txt
python script/wlistToGram.py txt/wlist_telex.txt txt/gram.txt

# wdnet.txt
htk/HParse txt/gram.txt txt/wdnet.txt

# Step 2 - the Dictionary
# srcDict
python script/splitWord.py txt/wlist.txt txt/srcDict_t.txt
python script/vietnameseToTelex.py txt/srcDict_t.txt txt/srcDict_t.txt
perl script/sort.pl txt/srcDict_t.txt txt/srcDict.txt

# HTK Dict & monophones
htk/HDMan -m -w txt/wlist_telex.txt -n phones/monophones -l txt/dict_log.txt txt/dict.txt txt/srcDict.txt

# Other monophoes
perl script/mkMonophones.pl phones/monophones phones/monophones0 phones/monophones1

# Step 3 - Recording the Data
# Using Vivos datasets https://ailab.hcmus.edu.vn/vivos

# Step 4 - Creating the Transcription Files
# MLF words
perl script/prompts2mlf.pl mlf/words.mlf txt/prompts_test_telex.txt

# MLF phones
htk/HLEd -l "*" -d txt/dict.txt -i mlf/phones0.mlf ins/mkphones0.led mlf/words.mlf
htk/HLEd -l "*" -d txt/dict.txt -i mlf/phones1.mlf ins/mkphones1.led mlf/words.mlf

# Step 5 - Coding the Data
# Generating training file list
python script/listwavmfc.py datasets/train/waves/ txt/train.scp txt/train_mfc.scp

# Feature extraction
htk/HCopy -C cfg/HCopy.cfg -S txt/train.scp

echo "Preparing completed"

