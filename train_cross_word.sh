#!/bin/sh -v
set -xv

# Training cross-word triphone models
# Removing sp and sil in monophones
perl script/xw_mkMonophones.pl phones/monophones phones/xw_monophones

# Reuse triphone as fulllist
perl script/mkFullList.pl phones/xw_monophones phones/xw_fulllist


# hmm16
perl script/mkTree.pl 40 phones/xw_monophones txt/xw_tree.hed phones/xw_
cp phones/stats12 phones/xw_stats
htk/HHEd -B -H hmm/hmm12/macros -H hmm/hmm12/hmmdefs -M hmm/hmm16 txt/xw_tree.hed phones/xw_fulllist | tee txt/xw_log.txt


htk/HHEd -B -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -M hmm/hmm16 txt/xw_tree.hed phones/xw_fulllist | tee txt/xw_log.txt



echo RO 100.0 phones/xw_stats > txt/xw_tree.hed
perl script/mkclscript.pl TB 600 phones/xw_monophones >> txt/xw_tree.hed
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



##
htk/HLEd -n phones/xw_triphones1 -l "*" -i mlf/xw_wintri.mlf ins/xw_mktri.led mlf/aligned.mlf

# hmm16 from hmm9
htk/HHEd -B -H hmm/hmm9/macros -H hmm/hmm9/hmmdefs -M hmm/hmm16 ins/xw_mktri.hed phones/monophones1

# hmm17, hmm18
htk/HERest -B -C cfg/HERest.cfg -I mlf/xw_wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats17 -S txt/train_mfc.scp -H hmm/hmm16/macros -H hmm/hmm16/hmmdefs -M hmm/hmm17 phones/xw_triphones1
htk/HERest -B -C cfg/HERest.cfg -I mlf/xw_wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats18 -S txt/train_mfc.scp -H hmm/hmm17/macros -H hmm/hmm17/hmmdefs -M hmm/hmm18 phones/xw_triphones1

# Step 10 - Making Tied-State Triphones
# hmm13
perl script/mkFullList.pl phones/monophones0 phones/xw_fulllist
# ---> fulllist is configured in txt/tree.hed
perl script/mkTree.pl 40 phones/monophones0 txt/xw_tree.hed phones/xw_
cp phones/stats18 phones/xw_stats
htk/HHEd -B -H hmm/hmm18/macros -H hmm/hmm18/hmmdefs -M hmm/hmm19 txt/xw_tree.hed phones/xw_triphones1 | tee txt/log.txt

# hmm14, hmm15
htk/HERest -B -C cfg/HERest.cfg -I mlf/xw_wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats14 -S txt/train_mfc.scp -H hmm/hmm13/macros -H hmm/hmm13/hmmdefs -M hmm/hmm14 phones/tiedlist
htk/HERest -B -C cfg/HERest.cfg -I mlf/xw_wintri.mlf -t 250.0 150.0 1000.0 -s phones/stats15 -S txt/train_mfc.scp -H hmm/hmm14/macros -H hmm/hmm14/hmmdefs -M hmm/hmm15 phones/tiedlist

echo "Training completed"

