#!/bin/sh -x
set -x

# Recognizer Evaluation
# Step 11 - Recognizing the Test Data
# Evaluation prompts - number only
python script/generatePrompts.py c:/Active/WorkingProjects/anotherHTK/test/ test/prompts.txt
python script/vietnameseToTelex.py test/prompts.txt txt/test_prompts.txt
perl script/prompts2mlf.pl mlf/test_words.mlf txt/test_prompts.txt

# Evaluation file list
python script/listwavmfc.py c:/Active/WorkingProjects/anotherHTK/test/ txt/test.scp txt/test_mfc.scp

# Evaluation MLF
htk/x64/HCopy -C cfg/HCopy.cfg -S txt/test.scp

# Recognizing the Test Data
htk/x64/HVite -C cfg/HVite.cfg -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -S txt/test_mfc.scp -i mlf/recout.mlf -w txt/wdnet.txt txt/srcDict.txt phones/tiedlist

# Format results
htk/x64/HResults -I mlf/test_words.mlf phones/tiedlist mlf/recout.mlf | tee result.txt

read