#!/bin/sh -v
set -xv

# 1. Training cross-word triphone models
# Removing sp and sil in monophones
perl script/xw_mkMonophones.pl phones/monophones phones/xw_monophones

# Creating xw_triphones1
cp phones/triphones1 phones/xw_triphones1

# Creating xw_fulllist
perl script/mkFullList.pl phones/monophones phones/xw_fulllist

# hmm16
perl script/mkTree.pl 40 phones/xw_monophones txt/xw_tree.hed phones/xw_
cp phones/stats phones/xw_stats
htk/HHEd -B -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -M hmm/hmm16 txt/xw_tree.hed phones/xw_triphones1 | tee txt/log.txt


htk/HHEd -B -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -M hmm/hmm16 txt/xw_tree.hed phones/triphones1 | tee txt/xw_log.txt



echo RO 100.0 phones/xw_stats > txt/xw_tree.hed
perl script/mkclscript.pl TB 40 phones/xw_monophones >> txt/xw_tree.hed
echo "AU "phones/xw_fulllist"
CO "phones/xw_tiedlist"
ST "phones/xw_trees"" >> txt/xw_tree.hed

perl script/mkTree.pl 40 phones/xw_monophones txt/xw_tree.hed phones/xw_
cp phones/stats phones/xw_stats
cp phones/fulllist phones/xw_fulllist

perl script/mkFullList.pl phones/monophones0 phones/fulllist
htk/HHEd -B -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -M hmm/hmm16 txt/xw_tree.hed phones/xw_unseen | tee txt/xw_log.txt

htk/HHEd -B -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -M hmm/hmm16 ins/xw_mktri.hed phones/monophones1
htk/HLEd -n phones/xw_triphones1 -l "*" -i mlf/xw_wintri.mlf ins/xw_mktri.led mlf/aligned.mlf
htk/HHEd -B -H hmm/hmm9/macros -H hmm/hmm9/hmmdefs -M hmm/xw_hmm10 ins/mktri.hed phones/monophones1


# 2. Building Language Model
# Database preparation
htk/LNewMap -f WFC LMName gram/empty.wmap
htk/LGPrep -a 100000 -b 200000 -n 3 -d gram gram/empty.wmap datasets/collection.txt

# Language model generation
htk/LBuild -c 2 0 -c 3 0 gram/wmap gram/langmodel gram/gram.*

# Testing the LM perplexity
htk/LPlex -t gram/langmodel datasets/collection.txt | tee result_model.txt

echo "Training completed"

