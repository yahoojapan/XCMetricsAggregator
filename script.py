import subprocess
import os
import json
import pprint
import getpass
import datetime
import requests
import pandas as pd
import numpy as np
import csv

res = subprocess.call('osascript {}/xcode_metrics_automation.applescript'.format(os.getcwd()), shell=True)
print(res)
if res != 0:
   print(datetime.datetime.today())
   print("ERROR!!")
   exit()
def find_all_files(directory):
    for root, dirs, files in os.walk(directory):
        yield root
        for file in files:
            yield os.path.join(root, file)

def isJsonFormat(line):
    try:
        json.loads(line)
    except json.JSONDecodeError as e:
        print(e)
        return False
    except ValueError as e:
        print(e)
        return False
    except Exception as e:
        print(e)
        return False
    return True

def getAlliPhonesPoints(identifier, category):
    section = list(filter(lambda x: x["identifier"] == identifier, category["sections"]))
    if section == [] or section[0]["datasets"] == []:
        return []

    points = list(filter(lambda x: x["filterCriteria"]["device"] == "all_iphones", section[0]["datasets"]))[0]["points"]
    return points

bundleIdList = list("")
for file in find_all_files('/Users/' + getpass.getuser() + '/Library/Developer/Xcode/Products/'):
    if (file.endswith("Metrics.xcmetricsdata")):

        bundleId = file.split("/")[7]
        if (bundleId.startswith("com.cf")):
            continue

        f = open(file, 'r')
        jsonData = json.load(f)

        performance = list(filter(lambda x: x["identifier"] == "performance", jsonData["categories"]))[0]

        dataList = list("")
        dataList.append(file.split("/")[7])
        allHangRatePoints = getAlliPhonesPoints("hangRate", performance)
        if allHangRatePoints != []:
            print("Hang Rate iPhone(All)")
            dataList.append(allHangRatePoints[-1]["summary"])

        allLaunchTimePoints = getAlliPhonesPoints("launchTime", performance)
        if allLaunchTimePoints != []:
            print("Launch Time iPhone(All)")
            dataList.append(allLaunchTimePoints[-1]["summary"])

        allPeakMemoryPoints = getAlliPhonesPoints("peakMemory", performance)
        if allPeakMemoryPoints != []:
            print("Peak Memory iPhone(All)")
            dataList.append(allPeakMemoryPoints[-1]["summary"])

        allAverageMemoryPoints = getAlliPhonesPoints("averageMemory", performance)
        if allAverageMemoryPoints != []:
            print("Average Memory iPhone(All)")
            dataList.append(allAverageMemoryPoints[-1]["summary"])

        diskUsage = list(filter(lambda x: x["identifier"] == "diskUsage", jsonData["categories"]))[0]
        allDiskWritesPoints = getAlliPhonesPoints("diskWrites", diskUsage)
        if allDiskWritesPoints != []:
            print("Disk Writes iPhone(All)")
            dataList.append(allDiskWritesPoints[-1]["summary"])

        batteryUsage = list(filter(lambda x: x["identifier"] == "batteryUsage", jsonData["categories"]))[0]
        allOnScreenPoints = getAlliPhonesPoints("onScreen", batteryUsage)
        if allOnScreenPoints != []:
            print("On Screen Usage(All)")
            dataList.append( allOnScreenPoints[-1]["summary"])

        allBackgroundPoints = getAlliPhonesPoints("background", batteryUsage)
        if allBackgroundPoints != []:
            print("Background Battery Usage(All)")
            dataList.append(allBackgroundPoints[-1]["summary"])
        bundleIdList.append(dataList)
        f.close()

with open('result.csv', 'w') as file:
    writer = csv.writer(file, lineterminator='\n')
    writer.writerows(bundleIdList)