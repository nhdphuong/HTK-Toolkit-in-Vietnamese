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

# Creating Monophone HMMs
# Step 6 - Creating Flat Start Monophones
# hmm0
htk/HCompV -C cfg/HCompV.cfg -f 0.01 -m -S txt/train_mfc.scp -M hmm/hmm0 ins/proto.template
perl script/mkMacrosFile.pl hmm/hmm0/vFloors hmm/hmm0/macros
perl script/mkHmmdefsFile.pl hmm/hmm0/proto phones/monophones0 hmm/hmm0/hmmdefs

# hmm1, hmm2, hmm3
htk/HERest -C cfg/HERest.cfg -I mlf/phones0.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm0/macros -H hmm/hmm0/hmmdefs -M hmm/hmm1 phones/monophones0
htk/HERest -C cfg/HERest.cfg -I mlf/phones0.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm1/macros -H hmm/hmm1/hmmdefs -M hmm/hmm2 phones/monophones0
htk/HERest -C cfg/HERest.cfg -I mlf/phones0.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm2/macros -H hmm/hmm2/hmmdefs -M hmm/hmm3 phones/monophones0

# Step 7 - Fixing the Silence Models
# hmm4
perl script/makesp.pl hmm/hmm3/hmmdefs hmm/hmm4/hmmdefs hmm/hmm3/macros hmm/hmm4/macros

# hmm5
htk/HHEd -H hmm/hmm4/macros -H hmm/hmm4/hmmdefs -M hmm/hmm5 ins/sil.hed phones/monophones1

# hmm6, hmm7
htk/HERest -C cfg/HERest.cfg -I mlf/phones1.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm5/macros -H hmm/hmm5/hmmdefs -M hmm/hmm6 phones/monophones1
htk/HERest -C cfg/HERest.cfg -I mlf/phones1.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm6/macros -H hmm/hmm6/hmmdefs -M hmm/hmm7 phones/monophones1

# Step 8 - Realigning the Training Data
cp mlf/phones1.mlf mlf/aligned.mlf
htk/HVite -o SWT -b silence -a -H hmm/hmm7/macros -H hmm/hmm7/hmmdefs -i mlf/aligned.mlf -m -t 250.0 -y lab -I mlf/words.mlf -S txt/train_mfc.scp txt/srcDict.txt phones/monophones1
cp mlf/phones1.mlf mlf/aligned.mlf

# hmm8, hmm9
htk/HERest -C cfg/HERest.cfg -I mlf/aligned.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm7/macros -H hmm/hmm7/hmmdefs -M hmm/hmm8 phones/monophones1
htk/HERest -C cfg/HERest.cfg -I mlf/aligned.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm8/macros -H hmm/hmm8/hmmdefs -M hmm/hmm9 phones/monophones1

# Creating Tied-State Triphones
# Step 9 - Making Triphones from Monophones
# If using mktri.hed then sil and sp will not be tie
#htk/HLEd -n phones/triphones1 -l "*" -i mlf/wintri.mlf ins/mktri.led mlf/aligned.mlf
htk/HLEd -n phones/triphones1 -l "*" -i mlf/wintri.mlf ins/xw_mktri.led mlf/aligned.mlf

# hmm10
perl script/mkTriHed.pl phones/monophones1 phones/triphones1 txt/mktri.hed
htk/HHEd -B -H hmm/hmm9/macros -H hmm/hmm9/hmmdefs -M hmm/hmm10 txt/mktri.hed phones/monophones1

# hmm11, hmm12
htk/HERest -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats11 -S txt/train_mfc.scp -H hmm/hmm10/macros -H hmm/hmm10/hmmdefs -M hmm/hmm11 phones/triphones1
htk/HERest -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats12 -S txt/train_mfc.scp -H hmm/hmm11/macros -H hmm/hmm11/hmmdefs -M hmm/hmm12 phones/triphones1

# Step 10 - Making Tied-State Triphones
# hmm13
perl script/mkFullList.pl phones/monophones1 phones/fulllist
# ---> fulllist is used in txt/tree.hed
perl script/mkTree.pl 350 phones/monophones1 txt/tree.hed phones/
cp phones/stats12 phones/stats
htk/HHEd -B -H hmm/hmm12/macros -H hmm/hmm12/hmmdefs -M hmm/hmm13 txt/tree.hed phones/triphones1 | tee txt/log.txt

# hmm14, hmm15
htk/HERest -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats14 -S txt/train_mfc.scp -H hmm/hmm13/macros -H hmm/hmm13/hmmdefs -M hmm/hmm14 phones/tiedlist
htk/HERest -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats15 -S txt/train_mfc.scp -H hmm/hmm14/macros -H hmm/hmm14/hmmdefs -M hmm/hmm15 phones/tiedlist

echo "Training completed"

