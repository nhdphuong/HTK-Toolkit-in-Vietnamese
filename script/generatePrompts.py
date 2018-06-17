#!/usr/bin/env python
# coding=utf-8

import os
import sys
import fileinput
import re
from fnmatch import fnmatch

# Usage: script path_to_wav path_to_output")

root      = sys.argv[1]
f_output = open(sys.argv[2], "w", encoding="utf-8")
pattern   = "*.wav"
number = {
    0: "KHÔNG",
    1: "MỘT",
    2: "HAI",
    3: "BA",
    4: "BỐN",
    5: "NĂM",
    6: "SÁU",
    7: "BẢY",
    8: "TÁM",
    9: "CHÍN"
}

for path, subdirs, files in os.walk(root):
    for name in files:
        if fnmatch(name, pattern):
            f_output.write(name.replace(".wav", " ").replace("\\", "/"))
            for i in range(0, 10):
                if fnmatch(name, "*0" + str(i) + ".wav"):
                    f_output.write(number[i] + " ")
            f_output.write("\n")
