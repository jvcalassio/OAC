import os

for file in os.listdir("./bmp"):
	if(file.endswith(".bmp")):
		fname = file.split('.')
        if(fname[0] != "main"):
    		os.system("./convbmp " + fname[0])
