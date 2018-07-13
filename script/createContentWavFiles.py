#!/usr/bin/env python
# coding=utf-8

import os
import sys
import fileinput
import re
from pydub import AudioSegment

# Preparing the file
f_input1  = open(sys.argv[1], "r", encoding="utf-8")
f_input2  = open(sys.argv[2], "r", encoding="utf-8")
data_path = sys.argv[3]
result_audio_name = sys.argv[4]
f_output = open(sys.argv[5], "w", encoding="utf-8")

# Convert number to string 
def numbers_to_strings(argument):
    switcher = {
        "0": "khoong",
        "1": "moojt",
        "2": "hai",
        "3": "ba",
        "4": "boosn",
        "5": "nawm",
        "6": "sasu",
        "7": "bary",
        "8": "tasm",
        "9": "chisn",
    }
    return switcher.get(argument, "nothing")

# Read file input and create number string list
def create_num_string_list(argument):
	result_text_list = []

	for letter in argument:
		char = numbers_to_strings(letter);
		if char != "nothing":
			result_text_list.append(char + "\n")
			
	return result_text_list

# Read file words.mlf 
def readWords(file):
	filename = ""
	contentList = {}
	lines = file.readlines()
	for i in range(0, len(lines)):
		line = lines[i]
		if "'*'/" in line:
			filename = line[5:len(line)-5] + "wav"
		elif len(line) == 1 and '.' in line:
			continue
		elif '#!MLF!#' in line:
			continue
		else:
			row = line.split(' ')
			if len(row) == 5 and 'silence' not in line:
				start = row[0]
				end = row[0]
				letter = row[4]
				if letter not in contentList.keys():
					contentList[row[4]] = {}
				if filename not in contentList[letter].keys():
					contentList[letter][filename] = []
				for j in range(i+1, len(lines)):
					spline = lines[j]
					if 'sp' in spline:
						end = spline.split(' ')[0]
						i = j + 1
						break
			
				contentList[letter][filename].append({'start': start, 'end': end})
			else:
				continue
	return contentList

# Write data restructure
def write_restructure_data(contentList):
	for line in contentList.keys():
		temp = line + ":{ \n"
		for file_path in contentList[line].keys():
			time = str(contentList[line][file_path])
			temp += file_path + ": " + time + "\n"
		temp+= "}\n"
		f_output.write(temp)
	f_output.write("\n")
	
# create output wav file
def create_output_wav_file(contentList):
	i = 0
	newAudioList = []
	for letter in result_text_list:
		if letter in contentList.keys():
			wave_path = next(iter(contentList[letter]))
			time = list(next(iter(contentList[letter][wave_path])).values())
			start = int(int(time[0]) / 10000)
			end = int(int(time[1]) / 10000)
			newAudio = AudioSegment.from_wav(data_path + "/" + wave_path)
			newAudio = newAudio[start:end]
			if i == 0:
				combinedAudio = newAudio
			else:
				combinedAudio = combinedAudio + newAudio
			i += 1
		
	combinedAudio.export(result_audio_name, format="wav")

result_text_list = create_num_string_list(f_input2.read())
contentList = readWords(f_input1)
write_restructure_data(contentList)
create_output_wav_file(contentList)

# Closing the file
f_input1.close()
f_input2.close()
f_output.close()