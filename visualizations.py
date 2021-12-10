#%%
import pandas as pd
import numpy as np
import xml.etree.ElementTree as ET
import seaborn as sb
import matplotlib.pyplot as plt

#%%
NO_REPETITIONS = 10
OUTPUT_NAME = 'outputBaby.csv'
data = pd.read_csv(OUTPUT_NAME)

def trimFunc(name):
    if name[-2] != '_':
        return name[:-3]
    return name[:-2]


data['name'] = data['name'].apply(trimFunc)

data[data.columns[data.columns.str.contains(
    'speed',case=False)]] = data[data.columns[data.columns.str.contains('speed',case=False)]].apply(
        lambda x: x*3.6)

#%% LOW FLOW
data_800 = data[data['name'].str.match('conservative_800')]
data_800['name'] = data_800['name'].str.replace('conservative_800', 'pen')

#%%   Low flow - SPEED
dataMelt = data_800.melt(
    id_vars='name', value_vars=data_800.columns[data_800.columns.str.match('.+_speed')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(ylim=(70, 110), xlabel='Penetration rate',
       title='Penetration vs speed on detectors')

#%% Low flow - Occupancy
dataMelt = data_800.melt(
    id_vars='name', value_vars=data_800.columns[data_800.columns.str.match('.+_occupancy')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(xlabel='Penetration rate', title='Penetration vs occupancy on detectors')

#%% Low flow - flow
dataMelt = data_800.melt(
    id_vars='name', value_vars=data_800.columns[data_800.columns.str.match('.+_flow')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(ylim=(200, 500), xlabel='Penetration rate',
       title='Penetration vs flow on detectors')

#%% Low flow - Overall speed
dataMelt = data_800.melt(
    id_vars='name', value_vars=data_800.columns[data_800.columns.str.match('overallSpeed')])
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(ylim=(60, 90), xlabel='Penetration rate',
       title='Penetration vs overall speed')

#%% Low flow - Sampled secs
dataMelt = data_800.melt(
    id_vars='name', value_vars=data_800.columns[data_800.columns.str.match('sampledSeconds')])
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(ylim=(100_000, 145_000), xlabel='Penetration rate',
       title='Penetration vs total travel time', ylabel='Vehicle seconds')


#%% MODERATE FLOW
data_1200 = data[data['name'].str.match('conservative_1200')]
data_1200['name'] = data_1200['name'].str.replace('conservative_1200', 'pen')

#%%   Moderate flow - SPEED
dataMelt = data_1200.melt(
    id_vars='name', value_vars=data_1200.columns[data_1200.columns.str.match('.+_speed')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set( ylim=(50, 110),xlabel='Penetration rate',
       title='Penetration vs speed on detectors',
       ylabel = 'speed [km/h]')

#%% Moderate flow - Occupancy
dataMelt = data_1200.melt(
    id_vars='name', value_vars=data_1200.columns[data_1200.columns.str.match('.+_occupancy')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(xlabel='Penetration rate', title='Penetration vs speed on detectors',
ylabel = 'occupandy [%]')

#%% Moderate flow - flow
dataMelt = data_1200.melt(
    id_vars='name', value_vars=data_1200.columns[data_1200.columns.str.match('.+_flow')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(ylim=(300, 800), xlabel='Penetration rate',
       title='Penetration vs flow on detectors')

#%% Moderate flow - Overall speed
dataMelt = data_1200.melt(
    id_vars='name', value_vars=data_1200.columns[data_1200.columns.str.match('overallSpeed')])
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(ylim=(60, 90), xlabel='Penetration rate',
       title='Penetration vs overall speed')

#%% Moderate flow - Sampled secs
dataMelt = data_1200.melt(
    id_vars='name', value_vars=data_1200.columns[data_1200.columns.str.match('sampledSeconds')])
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(ylim=(100_000, 250_000), xlabel='Penetration rate',
       title='Penetration vs total travel time', ylabel='Vehicle seconds')


#%% HIGH FLOW
data_1600 = data[data['name'].str.match('conservative_1600')]
data_1600['name'] = data_1600['name'].str.replace('conservative_1600', 'pen')

#%%   High flow - SPEED
dataMelt = data_1600.melt(
    id_vars='name', value_vars=data_1600.columns[data_1600.columns.str.match('.+_speed')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(ylim=(30, 100), xlabel='Penetration rate',
       title='Penetration vs speed on detectors',
       ylabel = 'speed [km/h]')

#%% High flow - Occupancy
dataMelt = data_1600.melt(
    id_vars='name', value_vars=data_1600.columns[data_1600.columns.str.match('.+_occupancy')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(xlabel='Penetration rate', title='Penetration vs speed on detectors',
ylabel = 'occupancy [%]')

#%% High flow - flow
dataMelt = data_1600.melt(
    id_vars='name', value_vars=data_1600.columns[data_1600.columns.str.match('.+_flow')])
ax = sb.catplot(x='name', y='value', hue='variable', kind='bar', data=dataMelt)
ax.set(ylim=(400, 1000), xlabel='Penetration rate',
       title='Penetration vs flow on detectors')

#%% High flow - Overall speed
dataMelt = data_1600.melt(
    id_vars='name', value_vars=data_1600.columns[data_1600.columns.str.match('overallSpeed')])
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(ylim=(40, 90), xlabel='Penetration rate',
       title='Penetration vs overall speed')

#%% High flow - Sampled secs
dataMelt = data_1600.melt(
    id_vars='name', value_vars=data_1600.columns[data_1600.columns.str.match('sampledSeconds')])
ax = sb.catplot(x='name', y='value', kind='bar', data=dataMelt)
ax.set(ylim=(200_000, 600_000), xlabel='Penetration rate',
       title='Penetration vs total travel time', ylabel='Vehicle seconds')

#%% VISSIM 

dataV = pd.read_csv('Results_vissim.csv',sep=';',decimal=',')
dataV.penetration = dataV.penetration.astype(str)

#%%
speeds = ['SpeedAvg_all','HarmSpeed_all','ArithSpeed_all']
dataScope = dataV[dataV['flou']=='med']

#%%
dataMelt = dataScope[['penetration','SpeedAvg_all']]
ax = sb.catplot(x='penetration',y='SpeedAvg_all',data = dataMelt,kind = 'bar')
ax.set(ylim=(60,100))

#%%
dataMelt = dataScope[['penetration','TTT_all']]
ax = sb.catplot(x='penetration',y='TTT_all',data = dataMelt,kind = 'bar')
ax.set(ylim=(200_000,270_000), title = 'Penetration vs total travel time',
ylabel = 'vehicle seconds')

#%%
dataComp = pd.DataFrame()
dataComp['penetration'] = data_1200['name'].apply(lambda x: x[x.index('_')+1:])
dataComp['TTT_all'] = data_1200.sampledSeconds
dataComp['source'] = 'Sumo'
dataScope['source'] = 'Vissim'
dataAppend = dataComp.append(dataScope[['TTT_all','penetration','source']])

ax = sb.catplot(data=dataAppend, x='penetration',
                y='TTT_all', hue='source', kind='bar')
ax.set(title='Total travel time - Sumo x Vissim',
       ylabel='vehicle seconds', xlabel='penetration [%]')

#%%
dataVdet = pd.read_csv('det_results.csv',decimal=',',sep=';')
dataVdet = dataVdet.drop(dataVdet.columns[dataVdet.columns.str.contains('procenta')],axis=1)
dataVdet = dataVdet.drop('Sim',axis=1)

# %% COMPARISON

def mappingFunc(columnName):
    mapDict = {
        '200' : 'L6',
        '300' : 'L4',
        '400' : 'L10005',
        '500' : 'L10',
        '600' : 'L10008'
    }

    try:
        dashIndex = columnName.index('_')
    except:
        return columnName

    truncName = columnName[:dashIndex]

    if mapDict.get(truncName):
        return mapDict[truncName]+columnName[dashIndex:]
    else: return columnName

dataVdet.columns = list(map(mappingFunc,dataVdet.columns.values))
#%%
dataVdet_low = dataVdet[dataVdet.flou=='low']

#%%
dataMelt = dataVdet_low.melt(
    id_vars='penetration',
    value_vars=dataVdet_low.columns[dataVdet_low.columns.str.contains(
        '_occupancy')]
)
ax = sb.catplot(x='penetration', y='value',
                hue='variable', kind='bar', data=dataMelt)
ax.set(title = 'Penetration vs occupancy on detectors',ylabel = 'occupancy [%]')                

#%%
dataMelt = dataVdet_low.melt(
    id_vars='penetration',
    value_vars=dataVdet_low.columns[dataVdet_low.columns.str.contains(
        '_speed_h')]
)
ax = sb.catplot(x='penetration', y='value',
                hue='variable', kind='bar', data=dataMelt)
ax.set(title = 'Penetration vs speed on detectors',ylabel = 'speed [km/h]',
ylim=(70,110))                


# %%
dataVdet_med = dataVdet[dataVdet.flou=='med']

#%%
dataMelt = dataVdet_med.melt(
    id_vars='penetration',
    value_vars=dataVdet_med.columns[dataVdet_med.columns.str.contains(
        '_occupancy')]
)
ax = sb.catplot(x='penetration', y='value',
                hue='variable', kind='bar', data=dataMelt)
ax.set(title = 'Penetration vs occupancy on detectors',ylabel = 'occupancy [%]')

#%%
dataMelt = dataVdet_med.melt(
    id_vars='penetration',
    value_vars=dataVdet_med.columns[dataVdet_med.columns.str.contains(
        '_speed_h')]
)
ax = sb.catplot(x='penetration', y='value',
                hue='variable', kind='bar', data=dataMelt)
ax.set(title = 'Penetration vs speed on detectors',ylabel = 'speed [km/h]',
ylim = (60,110))

# %%
dataVdet_high = dataVdet[dataVdet.flou=='high']

#%%
dataMelt = dataVdet_high.melt(
    id_vars='penetration',
    value_vars=dataVdet_high.columns[dataVdet_high.columns.str.contains(
        '_occupancy')]
)
ax = sb.catplot(x='penetration', y='value',
                hue='variable', kind='bar', data=dataMelt)
ax.set(title = 'Penetration vs occupancy on detectors',ylabel = 'occupancy [%]')

#%%
dataMelt = dataVdet_high.melt(
    id_vars='penetration',
    value_vars=dataVdet_high.columns[dataVdet_high.columns.str.contains(
        '_speed_h')]
)
ax = sb.catplot(x='penetration', y='value',
                hue='variable', kind='bar', data=dataMelt)
ax.set(title = 'Penetration vs speed on detectors',ylabel = 'speed [km/h]',
ylim = (60,110))

#%% COMPARISON - L10008
dataComp = pd.DataFrame()
dataComp['penetration'] = data_800['name'].apply(lambda x: x[x.index('_')+1:])
dataComp['speed'] = data_800['L10008_speed']
dataComp['occupancy'] = data_800['L10008_occupancy']
dataComp['Source'] = 'Sumo'

dataTemp = dataVdet_low[['penetration','L10008_speed_h','L10008_occupancy']]
dataTemp.columns = ['penetration','speed','occupancy']
dataTemp['Source'] = 'Vissim'

dataComp  = dataComp.append(dataTemp)
dataComp.penetration = dataComp.penetration.astype(str)

#%%
ax = sb.catplot(x='penetration', y='speed',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Speed on detector "L10008" - Sumo x Vissim',
ylabel = 'Speed [km/h]', xlabel = 'penetration [%]')

#%%
ax = sb.catplot(x='penetration', y='occupancy',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Occupancy on detector "L10008" - Sumo x Vissim',
ylabel = 'occupancy [%]', xlabel = 'penetration [%]')

#%% COMPARISON - L10008
dataComp = pd.DataFrame()
dataComp['penetration'] = data_1200['name'].apply(lambda x: x[x.index('_')+1:])
dataComp['speed'] = data_1200['L10008_speed']
dataComp['occupancy'] = data_1200['L10008_occupancy']
dataComp['Source'] = 'Sumo'

dataTemp = dataVdet_med[['penetration','L10008_speed_h','L10008_occupancy']]
dataTemp.columns = ['penetration','speed','occupancy']
dataTemp['Source'] = 'Vissim'

dataComp  = dataComp.append(dataTemp)
dataComp.penetration = dataComp.penetration.astype(str)

#%%
ax = sb.catplot(x='penetration', y='speed',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Speed on detector "L10008" - Sumo x Vissim',
ylabel = 'Speed [km/h]', xlabel = 'penetration [%]')

#%%
ax = sb.catplot(x='penetration', y='occupancy',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Occupancy on detector "L10008" - Sumo x Vissim',
ylabel = 'occupancy [%]', xlabel = 'penetration [%]')

#%% COMPARISON - L10008
dataComp = pd.DataFrame()
dataComp['penetration'] = data_1600['name'].apply(lambda x: x[x.index('_')+1:])
dataComp['speed'] = data_1600['L10008_speed']
dataComp['occupancy'] = data_1600['L10008_occupancy']
dataComp['Source'] = 'Sumo'

dataTemp = dataVdet_high[['penetration','L10008_speed_h','L10008_occupancy']]
dataTemp.columns = ['penetration','speed','occupancy']
dataTemp['Source'] = 'Vissim'

dataComp  = dataComp.append(dataTemp)
dataComp.penetration = dataComp.penetration.astype(str)

#%%
ax = sb.catplot(x='penetration', y='speed',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Speed on detector "L10008" - Sumo x Vissim',
ylabel = 'Speed [km/h]', xlabel = 'penetration [%]')

#%%
ax = sb.catplot(x='penetration', y='occupancy',
                hue='Source', data=dataComp, kind='bar')
ax.set(title = 'Occupancy on detector "L10008" - Sumo x Vissim',
ylabel = 'occupancy [%]', xlabel = 'penetration [%]')

# %%
