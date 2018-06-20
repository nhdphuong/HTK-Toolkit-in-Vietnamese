#!/usr/bin/env python
# coding=utf-8

import os
import sys
import fileinput
import string
import re

if (len(sys.argv) != 4):
    print("usage: script collection prompts output")
    sys.exit()

# Preparing the file
f_input1 = open(sys.argv[1], "r", encoding="utf-8")
f_input2 = open(sys.argv[2], "r", encoding="utf-8")
f_output = open(sys.argv[3], "w", encoding="utf-8")

# Replace the target string
for line in f_input1:
    f_output.write(line)
f_input1.close()

for line in f_input2:
    line = re.sub(r"[^ ]* (.*)", r"<s> \1 </s>", line)
    f_output.write(line)
f_input2.close()

f_output.close()
