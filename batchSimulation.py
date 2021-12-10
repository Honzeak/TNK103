import xml.etree.ElementTree as ET
import traci as tc
import argparse
import os
import time

PATH_TO_FLOW_FILE = 'flows.rou.xml'
PATH_TO_SUMO_BINARY = r"C:\Program Files (x86)\Eclipse\Sumo\bin\sumo.exe"
NO_REPETITIONS = 10

#Get current directory
CWD = os.getcwd()

#Setup arguments for script
parser = argparse.ArgumentParser()
# parser.add_argument('simulation_step', type=int, help='Step length for simulation')
parser.add_argument('penetration_step', type=int, help='Percentage step for AV penetration')
parser.add_argument('flow_low', type=int, help='Low flow value')
parser.add_argument('flow_med', type=int, help='Medium flow value')
parser.add_argument('flow_high', type=int, help='High flow value')

args = parser.parse_args()

if (100 / args.penetration_step - 100//args.penetration_step) != 0:
    parser.error('Penetration steps must add to 100')

noSteps = 100//args.penetration_step

if not (args.flow_low<args.flow_med and args.flow_med<args.flow_high):
    parser.error('Lower flow has higher value than higher flow')

penetrations = [args.penetration_step*x/100 for x in range(noSteps+1)]
flows = [args.flow_low, args.flow_med, args.flow_high]
types = ['conservative', 'moderate', 'aggressive']

# Define steps where logging happens
logSteps = [400*x for x in range(1,10)]

#Parse flow definition XML
tree = ET.parse(PATH_TO_FLOW_FILE)
root = tree.getroot()

for type in types:
    for flow in flows:
        for penetration in penetrations:
            penetrationDisplay = int(penetration*100)
            for repetition in range(1,NO_REPETITIONS+1):

                # Manual flows (+1 because SUMO doesn't like zeroes)
                root[0].attrib['vehsPerHour'] = str(int((1-penetration)*.8*flow+1))
                root[1].attrib['vehsPerHour'] = str(int((1-penetration)*.2*flow+1))
                root[2].attrib['vehsPerHour'] = str(int((1-penetration)*.4*flow+1))

                # AV flows
                root[3].attrib['vehsPerHour'] = str(int(penetration*.8*flow+1))
                root[4].attrib['vehsPerHour'] = str(int(penetration*.2*flow+1))
                root[5].attrib['vehsPerHour'] = str(int(penetration*.4*flow+1))

                # AV type
                root[3].attrib['type'] = type
                root[3][0].attrib['value'] = type
                root[4].attrib['type'] = type
                root[4][0].attrib['value'] = type
                root[5].attrib['type'] = type
                root[5][0].attrib['value'] = type

                tree.write(PATH_TO_FLOW_FILE)

                #Command to launch simulation engine
                sumoCmd = [PATH_TO_SUMO_BINARY, "-c", "motorway.sumocfg","--random"]

                print(f'Starting simulation for {type} type with {penetrationDisplay} penetration with base flow of {flow}, run no. {repetition}.')

                #Start simulation
                tc.start(sumoCmd)
                step = 0
                while step < 36000:
                    tc.simulationStep()
                    # if step in logSteps:
                    #     print(f'Step {step}')
                    step += 1

                tc.close()

                print('Simulation ended successfully.')

                outputFolderName = f'output_{type}_{flow}_{penetrationDisplay}_{repetition}'
                outputFolderPath = os.path.join(CWD,outputFolderName)

                time.sleep(2)

                if os.path.isdir(outputFolderPath):
                    os.rmdir(outputFolderPath)
                    print(f'Overwriting existing directory ({outputFolderName})')

                os.rename(os.path.join(CWD,"output"), outputFolderPath)
                os.mkdir(os.path.join(CWD,'output'))

print('##################################################################')
print('Simulation run ended')