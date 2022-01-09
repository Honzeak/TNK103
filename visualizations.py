#%%
import pandas as pd
import numpy as np
import xml.etree.ElementTree as ET
import seaborn as sb
import matplotlib.pyplot as plt
from batchSimulation import NO_REPETITIONS, FLOWS
from outputTransform import OUTPUT_NAME

#%%
data = pd.read_csv(OUTPUT_NAME)

def trimFunc(name):
    if name[-2] != '_':
        return name[:-3]
    return name[:-2]


def mappingFunc(columnName):
    mapDict = {
        'L6':    'Begin',
        'L4':    'OffRamp',
        'L10005':'Mid',
        'L10':   'OnRamp',
        'L10008':'End'
    }

    try:
        dashIndex = columnName.index('_')
    except:
        return columnName

    truncName = columnName[:dashIndex]

    if mapDict.get(truncName):
        return mapDict[truncName]+columnName[dashIndex:]
    else: return columnName


data.columns = list(map(mappingFunc,data.columns.values))

data['name'] = data['name'].apply(trimFunc)

data[data.columns[data.columns.str.contains(
    'speed',case=False)]] = data[data.columns[data.columns.str.contains('speed',case=False)]].apply(
        lambda x: x*3.6)



flows = {'low':FLOWS[0],
         'med':FLOWS[1],
         'high':FLOWS[2]}

#%% define scope
flow = "high"
data_scope = data[data['name'].str.match(f'conservative_{flows[flow]}')]
data_scope['name'] = data_scope['name'].str.replace(f'conservative_{flows[flow]}', 'pen')

#%% SPEED
dataMelt = data_scope.melt(
    id_vars='name', value_vars=data_scope.columns[data_scope.columns.str.match('.+_speed')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(xlabel='Penetration rate', ylabel = 'Speed [km/h]',
       title='Penetration vs speed on detectors - SUMO')

#%% Occupancy
dataMelt = data_scope.melt(
    id_vars='name', value_vars=data_scope.columns[data_scope.columns.str.match('.+_occupancy')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(xlabel='Penetration rate [%]', title='Penetration vs occupancy on detectors - SUMO',ylabel = 'Occupancy [%]')

#%% flow
# dataMelt = data_scope.melt(
#     id_vars='name', value_vars=data_scope.columns[data_scope.columns.str.match('.+_flow')])
# ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
# ax.set(xlabel='Penetration rate [%]', ylabel = 'Flow [veh/h]',
#        title='Penetration vs flow on detectors - SUMO')

#%% Overall speed
# dataMelt = data_scope.melt(
#     id_vars='name', value_vars=data_scope.columns[data_scope.columns.str.match('overallSpeed')])
# ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
# ax.set(ylim=(60, 90), xlabel='Penetration rate [%]',ylabel = 'Speed [km/h]',
#        title='Penetration vs overall speed')

#%% Sampled secs
dataMelt = data_scope.melt(
    id_vars='name', value_vars=data_scope.columns[data_scope.columns.str.match('sampledSeconds')])
dataMelt['value'] = dataMelt['value']-dataMelt['value'].nsmallest(NO_REPETITIONS).mean()
dataMelt['value'] = dataMelt['value']/dataMelt['value'].max()*100
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(xlabel='Penetration rate [%]',
       title='Penetration vs relative travel time increase', ylabel='Travel time relative increase [%]')


#%% VISSIM 
dataV2 = pd.read_csv('vissim-data-overall.csv',sep=';',decimal=',')

#%% COMPARISON

dataComp = pd.DataFrame()
dataV2['source'] = 'Vissim'
dataV2.columns = ['flow','TTS','pen','source']

dataComp['pen'] = data_scope['name'].apply(lambda x: x[x.index('_')+1:]).astype(int)
dataComp['TTS'] = data_scope.sampledSeconds
dataComp['source'] = 'Sumo'

dataComp = dataComp.append(dataV2[dataV2.flow==flow].loc[:,['pen','TTS','source']])

dataCompSumo = dataComp[dataComp.source=='Sumo'].loc[:,'TTS']
dataCompVissim = dataComp[dataComp.source=='Vissim'].loc[:,'TTS']

#%%
mxSumo = dataCompSumo.nlargest(NO_REPETITIONS).mean()
mnSumo = dataCompSumo.nsmallest(NO_REPETITIONS).mean()
mxVissim = dataCompVissim.nlargest(NO_REPETITIONS).mean()
# bitchass
mnVissim = dataComp.query('source == "Vissim" & pen==0').TTS.mean()
#%%
dataComp['TTS'] = dataComp.apply(lambda x: (x.TTS/mnSumo-1)*100 if x.source == 'Sumo' else (x.TTS/mnVissim-1)*100, axis=1)

#%%

ax = sb.catplot(data=dataComp, x='pen',
                y='TTS', hue='source', kind='bar')
ax.set(title='Relative travel time increase - Sumo x Vissim',
       ylabel='Relative travel time increase [%]', xlabel='penetration [%]')

#%%
dataVdet2 = pd.read_csv('vissim-data-det.csv',decimal=',',sep=';')


def mappingFunc(thing):
    mapDict = {
        '200' :'Begin',
        '300' :'OffRamp',
        '400' :'Mid', 
        '500' :'OnRamp',
        '600' :'End' 
    }

    return mapDict[thing]

dataVdet2.DataCollectionMeasurement=dataVdet2.DataCollectionMeasurement.astype(str).apply(mappingFunc)
dataVdet2.OccupRate = dataVdet2.OccupRate * 100
#%%
dataVdet_scope = dataVdet2[dataVdet2.flou==flow]

#%%
ax = sb.catplot(x='penetrace', y='SpeedAvgArith',
                hue='DataCollectionMeasurement', kind='bar', data=dataVdet_scope)
ax.set(title = 'Penetration vs speed on detectors',ylabel = 'speed [km/h]',xlabel='Penetration [%]')                

#%%
ax = sb.catplot(x='penetrace', y='OccupRate',
                hue='DataCollectionMeasurement', kind='bar', data=dataVdet_scope)
ax.set(title = 'Penetration vs occupation on detectors',ylabel = 'occupation [%]',xlabel='Penetration [%]')                

#%% COMPARISON - L10008
dataComp = pd.DataFrame()
dataComp['Penetration'] = data_scope['name'].apply(lambda x: x[x.index('_')+1:])
dataComp['Speed'] = data_scope['End_speed']
dataComp['Occupancy'] = data_scope['End_occupancy']
dataComp['Source'] = 'Sumo'

dataTemp = dataVdet_scope.loc[dataVdet_scope.DataCollectionMeasurement=='End',['penetrace','SpeedAvgArith','OccupRate']]
dataTemp.columns = ['Penetration','Speed','Occupancy']
dataTemp['Source'] = 'Vissim'

dataComp  = dataComp.append(dataTemp)
dataComp.Penetration=dataComp.Penetration.astype(int)
dataComp.Source = dataComp.Source.astype(str)

#%%
ax = sb.catplot(x='Penetration', y='Speed',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Speed on detector "End" - Sumo x Vissim',
ylabel = 'Speed [km/h]', xlabel = 'penetration [%]')

#%%

mnSumo = dataComp.query('Penetration == 0 & Source == "Sumo"').Occupancy.mean()
mnVissim = dataComp.query('Penetration == 0 & Source == "Vissim"').Occupancy.mean()

dataComp['Occupancy'] = dataComp.apply(lambda x: (x.Occupancy/mnSumo-1)*100 if x.Source == 'Sumo' else (x.Occupancy/mnVissim-1)*100, axis=1)

#%%
ax = sb.catplot(x='Penetration', y='Occupancy',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Occupancy on detector "End" - Sumo x Vissim',
ylabel = 'occupancy [%]', xlabel = 'penetration [%]')


# %%
