import xml.etree.ElementTree as ET
import traci as tc
import argparse
import os
import time

PATH_TO_FLOW_FILE = 'flows.rou.xml'
PATH_TO_SUMO_BINARY = r"C:\Program Files (x86)\Eclipse\Sumo\bin\sumo.exe"
NO_REPETITIONS = 10

PENETRATIONS = [0, .15, .45, .70]
FLOWS = [1300, 2000, 2700]
TYPES = ['conservative', 'moderate', 'aggressive']

if __name__ == "__main__":

    #Get current directory
    CWD = os.getcwd()

    #Setup arguments for script
    parser = argparse.ArgumentParser()
    parser.add_argument('penetration', type=int,
                        help='penetration value')
    parser.add_argument('flow', type=int, help='flow value')
    parser.add_argument('type', type=str, help='AV type')

    args = parser.parse_args()

    penetration = args.penetration/100
    flow = args.flow
    type = args.type


    #Parse flow definition XML
    tree = ET.parse(PATH_TO_FLOW_FILE)
    root = tree.getroot()

    penetrationDisplay = int(penetration*100)

    # Manual flows (+1 because SUMO doesn't like zeroes)
    root[0].attrib['vehsPerHour'] = str(
        int((1-penetration)*.8*flow+1))
    root[1].attrib['vehsPerHour'] = str(
        int((1-penetration)*.2*flow+1))
    root[2].attrib['vehsPerHour'] = str(
        int((1-penetration)*500+1))

    # AV flows
    root[3].attrib['vehsPerHour'] = str(
        int(penetration*.8*flow+1))
    root[4].attrib['vehsPerHour'] = str(
        int(penetration*.2*flow+1))
    root[5].attrib['vehsPerHour'] = str(int(penetration*500+1))

    # AV type
    root[3].attrib['type'] = type
    root[3][0].attrib['value'] = type
    root[4].attrib['type'] = type
    root[4][0].attrib['value'] = type
    root[5].attrib['type'] = type
    root[5][0].attrib['value'] = type

    tree.write(PATH_TO_FLOW_FILE)

    print('XML rewritten.')

 