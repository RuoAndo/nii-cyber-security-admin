import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

wList = {}

counter=0
while line:
    wList[counter]=line.strip()
    line = f.readline() 
    counter = counter + 1
f.close()

# python 3.py warnlist csvlist-sorted | more 
f = open(argvs[2])
line = f.readline() 

tcounter = 0
while line:
    print line.strip()


    paList = {}
    for i in wList:
        paList[i] = 0
    
    ### csv ###
    f2 = open(line.strip())
    line2 = f2.readline()

    counter = 0
    while line2:
        tmp = line2.split(",")
        #print "--" + tmp[0]

        for i in wList:
            if tmp[0] == wList[i]:
                print "--" + tmp[0] + "," + str(i)
                paList[i] = tmp[1].strip()
         
        line2 = f2.readline() 
        counter = counter + 1

    print paList

    for i in paList:
        fname = "pa-" + str(i)
        f3 = open(fname,'a')
        f3.write(str(paList[i]) + "\n")
        f3.close()

    tcounter = tcounter + 1
    line = f.readline() 
    
    ### csv ###
    
#for i in wList:
    #print wList[i]
