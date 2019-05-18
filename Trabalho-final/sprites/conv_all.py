import os

for file in os.listdir("./bmp"):
	if(file.endswith(".bmp")):
		fname = file.split('.')
		os.system("./convbmp " + fname[0])