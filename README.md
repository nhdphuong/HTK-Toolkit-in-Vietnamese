# HTK-Toolkit-in-Vietnamese
Very simple script using HTK Toolkit of the Cambridge University Engineering Department in recognise Vietnamese speech of VIVOS Corpus datasets

> The Hidden Markov Model Toolkit (HTK) is a portable toolkit for building and manipulating hidden Markov models. HTK is primarily used for speech recognition research although it has been used for numerous other applications including research into speech synthesis, character recognition and DNA sequencing. HTK is in use at hundreds of sites worldwide.
> http://htk.eng.cam.ac.uk/

## Datasets
- VIVOS Corpus: https://ailab.hcmus.edu.vn/vivos
- Self recording speech for evaluation

## Datasets folder structure
- eval: contain data using for evaluate the hmm system. This folder contain speech in word level in each recording file.
--* waves: contain recording file in unique name. Each files is 1 word.
--* prompts.txt: each line is description of each file with template: file_id text.
- test: contain data using for recognizing. This folder contain speech in sentence level in each recording file.
--* waves: contain recording file in unique name. Each files is 1 sentence.
--* prompts.txt: each line is description of each file with template: file_id text.
- train: contain data using for create hmm system. This folder contain speech in sentence level in each recording file.
--* waves: contain recording file in unique name. Each files is 1 sentence.
--* prompts.txt: each line is description of each file with template: file_id text.
- collection.txt: a set of sentence that crawled from internet.
