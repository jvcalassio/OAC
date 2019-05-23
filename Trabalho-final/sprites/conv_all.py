import os

os.system("g++ -std=c++11 -o convbmp edited_bmp2isc.c")

for file in os.listdir("./bmp"):
	if(file.endswith(".bmp")):
		fname = file.split('.')
        if(fname[0] != "main"):
    		os.system("./convbmp " + fname[0])
