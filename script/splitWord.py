#!/usr/bin/env python
# coding=utf-8

import os
import sys
import fileinput
import re

# keyword
beginConsonants = "n g h|c h|g h|g i|k h|n h|n g|p h|t h|t r|q u"
endConsonants   = "c h|n h|n g"

# Preparing the file
f_input  = open(sys.argv[1], "r", encoding="utf-8")
f_output = open(sys.argv[2], "w", encoding="utf-8")

# Replace the target string
for line in f_input:
    line = line.lower()
    # re-write original word
    f_output.write(line.strip() + "\t")

    # write phones of the word: begin consonant + vowel + end consonant + sp
    line = " ".join(line).strip() + "\n"
    line = re.sub(r"^("+ beginConsonants +")", lambda match: match.group(1).replace(" ", ""), line, flags=re.IGNORECASE)
    line = re.sub(r"("+ endConsonants +")$", lambda match: match.group(1).replace(" ", ""), line, flags=re.IGNORECASE)
    line = line.replace("\n", " sp\n")
    f_output.write(line)
f_output.write("silence\tsil\n")

# Closing the file
f_input.close()
f_output.close()