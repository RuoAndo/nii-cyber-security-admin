import sys                                                                                                               
import re                                                                                                               
argvs = sys.argv                                                                                                         
argc = len(argvs)                                                                                                       
f = open(argvs[1])                                                                                                      
line = f.readline()                                                                                                     
while line:                                                                                                            
    tmp = line.split(",")                                                                                                
    print(tmp[7])                                                                                                  
    print(tmp[9])
    line = f.readline()                                                                                                 
f.close()
