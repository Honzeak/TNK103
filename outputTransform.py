#%%
import pandas as pd
import xml.etree.ElementTree as ET
from scipy.stats import t
import numpy as np

#%%
PATHROOT = 'C:/Users/Honza/OneDrive/Documents/!CVUT/_Magistr/III. Semestr/TNK103/SUMO network/outputs'
NO_REPETITIONS = 10

flows = ['800', '1200', '1600']
penetrations = ['0', '25', '50', '75', '100']
types = ['conservative', 'moderate', 'aggressive']
detectors = ['L4', 'L6', 'L10', 'L10005', 'L10008']

data = pd.DataFrame()

for avType in types:
    for flow in flows:
        for penetration in penetrations:
            for repetition in range(1,NO_REPETITIONS+1):

                try:
                    tree = ET.parse(
                        f'{PATHROOT}/output_{avType}_{flow}_{penetration}_{repetition}/output_linkData_vehs.xml')
                    root = tree.getroot()
                except:
                    print(f'linkData file for {avType}, {flow}, {penetration}, {repetition} not found')
                    continue

                ssSum = 0
                occupancySum = 0
                speedSum = 0

                for edge in root[0]:
                    ssSum += float(edge.attrib['sampledSeconds'])
                    speedSum += float(edge.attrib['speed'])

                    id = edge.attrib['id']
                    if id == "1":
                        departedMainDirection = int(edge.attrib['departed'])
                    if id == "9":
                        departedSecondaryDirection = int(edge.attrib['departed'])

                speedOverallAvg = speedSum/len(root[0])

                detectorParams = []

                for detector in detectors:
                    try:
                        root = ET.parse(
                            f'{PATHROOT}/output_{avType}_{flow}_{penetration}_{repetition}/outputLoop_{detector}.xml').getroot()
                    except:
                        print('Detector file not found')
                        continue

                    occupancySum = 0
                    speedSum = 0
                    speedCount = 0
                    flowSum = 0

                    for item in root:
                        occupancySum += float(item.attrib['occupancy'])
                        flowSum += float(item.attrib['flow'])
                        spd = item.attrib['speed']
                        if spd != '-1.00':
                            speedSum += float(spd)
                            speedCount += 1

                    occupancyAvg = occupancySum/len(root)
                    speedAvg = speedSum/speedCount
                    flowAvg = flowSum/len(root)

                    detectorParams.append((occupancyAvg, speedAvg, flowAvg))

                dict = {'name': f'{avType}_{flow}_{penetration}_{repetition}', 'departedMainDirection': departedMainDirection,
                        'departedSecondaryDirection': departedSecondaryDirection, 'sampledSeconds': ssSum, 'overallSpeed': speedOverallAvg}

                for detectorName, detectorValues in zip(detectors, detectorParams):
                    dict[detectorName+'_occupancy'] = detectorValues[0]
                    dict[detectorName+'_speed'] = detectorValues[1]
                    dict[detectorName+'_flow'] = detectorValues[2]

                data = data.append(dict, ignore_index=True)

data.to_csv('outputBaby.csv')
print('output file written')

#%%
noIters = []
outliers = {}
for i in range(len(data)//NO_REPETITIONS):
    for idx, item in data.iloc[:,3:].iteritems():
        mean = item[i*5:i*5+4].mean()
        stdev = item[i*5:i*5+4].std()
        epsilon = .10
        adjustedEpsilon = epsilon/(1+epsilon)
        alpha = .15
        noOfSimulations = ((stdev*t.ppf(1-(alpha/2),4))/(mean*epsilon))**2
        noIters.append(noOfSimulations)

advisedNoOfIterations = max(noIters)
print(advisedNoOfIterations)
# print(outliers)

#%%
for x in noIters:
    if x>=1:
        print(x)