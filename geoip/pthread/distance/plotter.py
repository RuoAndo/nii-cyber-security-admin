import pandas as pd
import matplotlib.pyplot as plt
import sys
import numpy as np

args = sys.argv

fig = plt.figure()

data1 = pd.read_csv(args[1],encoding = 'UTF8')
data1

data1_x = data1[data1.columns[0]]
data1_y = data1[data1.columns[1]]
ax1 = fig.add_subplot(2, 1, 1)

ax1.set_xlabel("IP")
ax1.set_ylabel("density") 
ax1.plot(data1_x, data1_y)

ticks = 5
plt.xticks(np.arange(0, len(data1_x), ticks), data1_x[::ticks], rotation=40)

####

data2 = pd.read_csv(args[2],encoding = 'UTF8')
data2

data2_x = data2[data2.columns[0]]
data2_y = data2[data2.columns[1]]
ax2 = fig.add_subplot(2, 1, 2)

ax2.set_xlabel("IP")
ax2.set_ylabel("density") 
ax2.plot(data2_x, data2_y)

ticks = 5
plt.xticks(np.arange(0, len(data2_x), ticks), data2_x[::ticks], rotation=40)


fig.tight_layout()
#fig.subplots_adjust()

#plt.title(args[1])
fig.show()
plt.show()
