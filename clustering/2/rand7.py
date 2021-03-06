# coding: UTF-8

import numpy as np
import matplotlib.pyplot as plt
from numpy.random import *
import sys

argvs = sys.argv
argc = len(argvs) 

if (argc != 3): 
    print 'Usage: # python d N range for ex, 6 * 1000 / 2 = 3000'
    quit()    

rng = np.random.RandomState(123)

# 6 * 1000 /2 = 3000 tmp

d = int(argvs[1])
N = int(argvs[2])
Rng = int(argvs[3])

dN = d * N

SRC = rand(dN) * Rng
DST = rand(dN) * Rng 

src = []
for x in SRC:
    src.append(int(x))

dst = []
for x in DST:
    dst.append(int(x))
    
mean = 5

x1 = rng.randn(N, d) + np.array([0,0,0,0,0,0])
x2 = rng.randn(N, d) + np.array([mean*2, mean, mean*2, mean, mean*2, mean])
x3 = rng.randn(N, d) + np.array([mean, mean*2, mean, mean*2, mean, mean*2])

x = np.concatenate((x1, x2, x3), axis=0)

counter = 0

for i in x1:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print str(src[counter]) + "," + str(dst[counter]) + "," + constr.rstrip(",")
    counter = counter + 1
    
for i in x2:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    #print constr.rstrip(",")
    print str(src[counter]) + "," + str(dst[counter]) + "," + constr.rstrip(",")
    counter = counter + 1

for i in x3:
    constr = ""
    for j in i:
        constr = constr + str(j) + ","
    print str(src[counter]) + "," + str(dst[counter]) + "," + constr.rstrip(",")
    counter = counter + 1
    #print constr.rstrip(",")
    
#print x1
#print x2

#plt.plot(x1, "o")
#plt.plot(x, "o")
#plt.show()

