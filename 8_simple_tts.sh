#!/bin/sh -v
set -xv

# Preparing file list
python script/listwavmfc.py datasets/train/waves/VIVOSSPK14/ txt/tts.scp txt/tts_mfc.scp

# Generating Forced Alignments
htk/HVite34 -l '*' -a -b silence -m -I mlf/words.mlf -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -i mlf/force_aligned.out txt/srcDict.txt phones/tiedlist -S txt/tts_mfc.scp

# Generating Speech from text
python script/createContentWavFiles.py mlf/force_aligned.out datasets/test_number.txt datasets/train/waves/VIVOSSPK14 result_tts.wav txt/tts_content.txt