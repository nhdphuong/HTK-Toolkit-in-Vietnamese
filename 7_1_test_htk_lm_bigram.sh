#!/bin/sh -v
set -xv

# Recognizing
htk/HDecode -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -S txt/testLM_mfc.scp -t 220.0 220.0 -C cfg/HDecode.cfg -i mlf/recoutBiLM.mlf -w gram/bigram/langmodel -p 0.0 -s 5.0 txt/dict.txt phones/tiedlist

# Format Results
htk/HResults -I mlf/testLM_words.mlf phones/tiedlist mlf/recoutBiLM.mlf | tee result_bi_lm.txt

