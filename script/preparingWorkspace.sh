#!/bin/sh

# Making some folders that stores files during training

mkdir -p mlf phones txt

for i in {0..15}
do
    j=$(($i-1));
    mkdir -p hmm/hmm$i
done