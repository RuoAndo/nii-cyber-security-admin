import sys
import re
import json
from datetime import datetime as dt

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1], 'r')
jsonData = json.load(f)

tmp = argvs[1].split("_")
datestr=str(dt.strptime(tmp[0],'%Y%m%d')).replace("-","/")

for i in jsonData:
    ip = i
    #print jsonData[ip]['system tags']
    if len(str(jsonData[ip]['system tags'])) > 10:
        #print str(ip)+ ":" + str(jsonData[ip]['system tags'])
        for x in jsonData[ip]['system tags']:
            print datestr + "," + str(ip) + "," + x.strip()



