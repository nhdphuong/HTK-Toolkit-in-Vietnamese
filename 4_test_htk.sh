#!/bin/sh -v
set -xv

# Recognizing the Test Data
htk/HVite -C cfg/HVite.cfg -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -S txt/eval_mfc.scp -i mlf/eval_recout.mlf -w txt/wdnet.txt txt/srcDict.txt phones/tiedlist

# Format results
htk/HResults -I mlf/eval_words.mlf phones/tiedlist mlf/eval_recout.mlf | tee result_eval.txt

