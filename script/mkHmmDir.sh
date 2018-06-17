#!/bin/sh

for i in {0..15}
do
    j=$(($i-1));
    mkdir -p hmm/hmm$i
done