#!/usr/bin/env python
# coding=utf-8

import os
import sys
import fileinput
import re

# Preparing the file
with open(sys.argv[1], encoding="utf-8") as f_input:
    f_str = f_input.read()
f_output = open(sys.argv[2], "w", encoding="utf-8")

# Replace the target string
f_str = re.sub(r"([^\s]*)(\s?)(.*?)(\n)", lambda match: match.group(1) + match.group(2) + match.group(3).lower() + match.group(4), f_str)

f_output.write(f_str)

# Closing the file
f_output.close()
