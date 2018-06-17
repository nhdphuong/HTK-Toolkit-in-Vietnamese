# Preparing folder for the run
sh script/preparingWorkspace.sh

# Preparing Data
# Step 1 - the Task Grammar
# prompts -> telex lower case
python script/vietnameseToTelex.py c:/Active/WorkingProjects/slp_htk_small/train_wav/prompts.txt txt/prompts.txt

# prompts -> wlist
perl script/prompts2wlist.pl txt/prompts.txt txt/wlist.txt

# gram.txt
python script/wlistToGram.py txt/wlist.txt txt/gram.txt

# wdnet.txt
htk/x64/HParse -T 1 txt/gram.txt txt/wdnet.txt

# Step 2 - the Dictionary
# srcDict
python script/splitWord.py txt/wlist.txt txt/srcDict.txt

# HTK Dict & monophones
htk/x64/HDMan -T 1 -m -w txt/wlist.txt -n phones/monophones -l dlog txt/dict.txt txt/srcDict.txt

# Other monophoes
perl script/mkMonophones.pl phones/monophones phones/monophones0 phones/monophones1

# Step 3 - Recording the Data
# Using Vivos datasets https://ailab.hcmus.edu.vn/vivos

# Step 4 - Creating the Transcription Files
# MLF words
perl script/prompts2mlf.pl mlf/words.mlf txt/prompts.txt

# MLF phones
htk/x64/HLEd -T 1 -l "*" -d txt/dict.txt -i mlf/phones0.mlf ins/mkphones0.led mlf/words.mlf
htk/x64/HLEd -T 1 -l "*" -d txt/dict.txt -i mlf/phones1.mlf ins/mkphones1.led mlf/words.mlf

# Step 5 - Coding the Data
# Generating training file list
python script/listwavmfc.py c:/Active/WorkingProjects/slp_htk_small/train_wav/waves/ txt/train.scp txt/train_mfc.scp

# Feature extraction
htk/x64/HCopy -T 1 -C cfg/HCopy.cfg -S txt/train.scp

# Creating Monophone HMMs
# Step 6 - Creating Flat Start Monophones
# hmm0
htk/x64/HCompV -T 1 -C cfg/HCompV.cfg -f 0.01 -m -S txt/train_mfc.scp -M hmm/hmm0 hmm/proto.template
perl script/mkMacrosFile.pl hmm/hmm0/vFloors hmm/hmm0/macros
perl script/mkHmmdefsFile.pl hmm/hmm0/proto phones/monophones0 hmm/hmm0/hmmdefs

# hmm1, hmm2, hmm3
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/phones0.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm0/macros -H hmm/hmm0/hmmdefs -M hmm/hmm1 phones/monophones0
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/phones0.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm1/macros -H hmm/hmm1/hmmdefs -M hmm/hmm2 phones/monophones0
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/phones0.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm2/macros -H hmm/hmm2/hmmdefs -M hmm/hmm3 phones/monophones0

# Step 7 - Fixing the Silence Models
# hmm4
perl script/makesp.pl hmm/hmm3/hmmdefs hmm/hmm4/hmmdefs hmm/hmm3/macros hmm/hmm4/macros

# hmm5
htk/x64/HHEd -T 1 -H hmm/hmm4/macros -H hmm/hmm4/hmmdefs -M hmm/hmm5 ins/sil.hed phones/monophones1

# hmm6, hmm7
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/phones1.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm5/macros -H hmm/hmm5/hmmdefs -M hmm/hmm6 phones/monophones1
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/phones1.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm6/macros -H hmm/hmm6/hmmdefs -M hmm/hmm7 phones/monophones1

# Step 8 - Realigning the Training Data
cp mlf/phones1.mlf mlf/aligned.mlf
htk/x64/HVite -T 1 -o SWT -b silence -a -H hmm/hmm7/macros -H hmm/hmm7/hmmdefs -i mlf/aligned.mlf -m -t 250.0 -y lab -I mlf/words.mlf -S txt/train_mfc.scp txt/srcDict.txt phones/monophones1
cp mlf/phones1.mlf mlf/aligned.mlf

# hmm8, hmm9
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/aligned.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm7/macros -H hmm/hmm7/hmmdefs -M hmm/hmm8 phones/monophones1
htk/x64/HERest -T 1 -C cfg/HERest.cfg -I mlf/aligned.mlf -t 250.0 150.0 1000.0 -S txt/train_mfc.scp -H hmm/hmm8/macros -H hmm/hmm8/hmmdefs -M hmm/hmm9 phones/monophones1

# Creating Tied-State Triphones
# Step 9 - Making Triphones from Monophones
htk/x64/HLEd -T 1 -n phones/triphones1 -l "*" -i mlf/wintri.mlf ins/mktri.led mlf/aligned.mlf

# hmm10
htk/x64/HHEd -T 1 -B -H hmm/hmm9/macros -H hmm/hmm9/hmmdefs -M hmm/hmm10 ins/mktri.hed phones/monophones1

# hmm11, hmm12
htk/x64/HERest -T 1 -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s stats -S txt/train_mfc.scp -H hmm/hmm10/macros -H hmm/hmm10/hmmdefs -M hmm/hmm11 phones/triphones1
htk/x64/HERest -T 1 -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s stats -S txt/train_mfc.scp -H hmm/hmm11/macros -H hmm/hmm11/hmmdefs -M hmm/hmm12 phones/triphones1

# Step 10 - Making Tied-State Triphones
# hmm13
perl script/mkFullList.pl phones/monophones0 phones/fulllist
# ---> fulllist is configured in ins/tree.hed
perl script/mkTree.pl 40 phones/monophones0 ins/tree.hed phones/fulllist
htk/x64/HHEd -B -H hmm/hmm12/macros -H hmm/hmm12/hmmdefs -M hmm/hmm13 ins/tree.hed phones/triphones1 > log.txt

# hmm14, hmm15
htk/x64/HERest -T 1 -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s stats -S txt/train_mfc.scp -H hmm/hmm13/macros -H hmm/hmm13/hmmdefs -M hmm/hmm14 tiedlist
htk/x64/HERest -T 1 -B -C cfg/HERest.cfg -I mlf/wintri.mlf -t 250.0 150.0 1000.0 -s stats -S txt/train_mfc.scp -H hmm/hmm14/macros -H hmm/hmm14/hmmdefs -M hmm/hmm15 tiedlist

# Recogniser Evaluation
# Step 11 - Recognising the Test Data
# Evaluation prompts - number only
python script/generatePrompts.py d:/OneDrive/CH/CH27-02/XuLyNgonNguNoi/TH/project/project2/test_wav/ test_wav/prompts.txt
python script/vietnameseToTelex.py test_wav/prompts.txt txt/test_prompts.txt
perl script/prompts2mlf.pl mlf/test_words.mlf txt/test_prompts.txt

# Evaluation file list
python script/listwavmfc.py d:/OneDrive/CH/CH27-02/XuLyNgonNguNoi/TH/project/project2/test_wav/ txt/test.scp txt/test_mfc.scp

# Evaluation MLF
htk/x64/HCopy -T 1 -C cfg/HCopy.cfg -S txt/test.scp

# Recognising the Test Data
htk/x64/HVite -T 1 -C cfg/Hvite.cfg -H hmm/hmm15/macros -H hmm/hmm15/hmmdefs -S txt/test.scp -i recout.mlf -w txt/wdnet.txt txt/srcDict.txt tiedlist

# Format results
htk/x64/HResults -I mlf/test_words.mlf tiedlist recout.mlf > result.txt

