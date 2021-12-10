clear
clc

feature('COM_SafeArraySingleDim', 1); % Matlab should only pass one-dimensional array to COM

%% Connecting the COM Server => Open a new Vissim Window:
Vissim = actxserver('Vissim.Vissim');
% If you have installed multiple Vissim Versions, you can open a specific Vissim version adding the version number
% Vissim = actxserver('Vissim.Vissim.10'); % Vissim 10
% Vissim = actxserver('Vissim.Vissim.21'); % Vissim 2021
Path_of_COM_Basic_Commands_network = 'C:\Users\richa\Desktop\UNI\3. semestr\TNK103\vissim project'; %'C:\Users\Public\Documents\PTV Vision\PTV Vissim 2021\Examples Training\COM\Basic Commands';

%% Load a Vissim Network:
Filename                = fullfile(Path_of_COM_Basic_Commands_network, 'Motorway_v1_manual_v1.inpx');
flag_read_additionally  = false; % you can read network(elements) additionally, in this case set "flag_read_additionally" to true
Vissim.LoadNet(Filename, flag_read_additionally);

%% Load a Layout:
Filename = fullfile(Path_of_COM_Basic_Commands_network, 'Motorway_v1_manual_v1.layx');
Vissim.LoadLayout(Filename);

%% ========================================================================
% Simulations:
%==========================================================================

% Delete all previous simulation runs first:
simRuns = Vissim.Net.SimulationRuns.GetAll; 
for simRunNo = 1 : length(simRuns)
    Vissim.Net.SimulationRuns.RemoveSimulationRun( simRuns{simRunNo} );
end

% set(Vissim.Evaluation, 'AttValue', 'VehNetPerf', true);
set(Vissim.Evaluation, 'AttValue', 'VehNetPerfCollectData', true);
set(Vissim.Evaluation, 'AttValue', 'VehNetPerfFromTime', 300);
set(Vissim.Evaluation, 'AttValue', 'DelaysCollectData', false);
set(Vissim.Evaluation, 'AttValue', 'DataCollCollectData', true);
set(Vissim.Evaluation, 'AttValue', 'DataCollFromTime', 300);
set(Vissim.Evaluation, 'AttValue', 'QueuesCollectData', false);
set(Vissim.Evaluation, 'AttValue', 'VehTravTmsCollectData', false);
set(Vissim.Evaluation, 'AttValue', 'VehClasses', '10,101');

% Activate QuickMode:
set(Vissim.Graphics.CurrentNetworkWindow, 'AttValue', 'QuickMode', 1)
Vissim.SuspendUpdateGUI; %  stop updating of the complete Vissim workspace (network editor, list, chart and signal time table windows)
End_of_simulation = 3900;
set(Vissim.Simulation, 'AttValue', 'SimPeriod', End_of_simulation);
Sim_break_at = 0; % simulation second [s] => 0 means no break!
set(Vissim.Simulation, 'AttValue', 'SimBreakAt', Sim_break_at);
% Set maximum speed:
set(Vissim.Simulation, 'AttValue', 'UseMaxSimSpeed', true);

TTTmat_typ1 = [];
SpeedAvgmat_typ1 = [];
TTTmat_typ2 = [];
SpeedAvgmat_typ2 = [];
TTTmat_typ3 = [];
SpeedAvgmat_typ3 = [];
TTTmat_typ4 = [];
SpeedAvgmat_typ4 = [];
TTTmat_typ5 = [];
SpeedAvgmat_typ5 = [];
TTTmat_all = [];
SpeedAvgmat_all = [];


for typecek = 1:5
    if typecek == 1
        Veh_composition_number = 1;
        Rel_Flows = Vissim.Net.VehicleCompositions.ItemByKey(Veh_composition_number).VehCompRelFlows.GetAll;
        set(Rel_Flows{1}, 'AttValue', 'VehType',        100); % Changing the vehicle type
        set(Rel_Flows{1}, 'AttValue', 'RelFlow',        1); % Changing the relative flow
        set(Rel_Flows{2}, 'AttValue', 'VehType',        1001);
        set(Rel_Flows{2}, 'AttValue', 'RelFlow',        0.001); % Changing the relative flow of the 2nd Relative Flow.
        set(Rel_Flows{3}, 'AttValue', 'VehType',        1002);
        set(Rel_Flows{3}, 'AttValue', 'RelFlow',        0.001)
        set(Rel_Flows{4}, 'AttValue', 'VehType',        1003);
        set(Rel_Flows{4}, 'AttValue', 'RelFlow',        0.001)
        
        for flou = 1:3
            if flou == 1
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 800; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 1 : 10
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 5);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ1(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ1(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                        
                    end
                end
            end

            if flou == 2
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1200; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 11 : 20
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 3);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ1(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ1(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                        
                    end
                end
            end

            if flou == 3
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1600; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 21 : 30
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ1(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ1(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                        
                    end
                end
            end
        end
    end
    
% next

    if typecek == 2
        Veh_composition_number = 1;
        Rel_Flows = Vissim.Net.VehicleCompositions.ItemByKey(Veh_composition_number).VehCompRelFlows.GetAll;
        set(Rel_Flows{1}, 'AttValue', 'VehType',        100); % Changing the vehicle type
        set(Rel_Flows{1}, 'AttValue', 'RelFlow',        0.75); % Changing the relative flow
        set(Rel_Flows{2}, 'AttValue', 'VehType',        1001);
        set(Rel_Flows{2}, 'AttValue', 'RelFlow',        0.25); % Changing the relative flow of the 2nd Relative Flow.
        set(Rel_Flows{3}, 'AttValue', 'VehType',        1002);
        set(Rel_Flows{3}, 'AttValue', 'RelFlow',        0.001)
        set(Rel_Flows{4}, 'AttValue', 'VehType',        1003);
        set(Rel_Flows{4}, 'AttValue', 'RelFlow',        0.001)
        
        for flou = 1:3
            if flou == 1
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 800; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 31 : 40
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 93);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ2(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ2(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 2
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1200; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 41 : 50
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 33);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ2(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ2(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 3
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1600; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 51 : 60
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 53);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ2(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ2(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end
        end
    end
    
%next
    
    if typecek == 3
        Veh_composition_number = 1;
        Rel_Flows = Vissim.Net.VehicleCompositions.ItemByKey(Veh_composition_number).VehCompRelFlows.GetAll;
        set(Rel_Flows{1}, 'AttValue', 'VehType',        100); % Changing the vehicle type
        set(Rel_Flows{1}, 'AttValue', 'RelFlow',        0.5); % Changing the relative flow
        set(Rel_Flows{2}, 'AttValue', 'VehType',        1001);
        set(Rel_Flows{2}, 'AttValue', 'RelFlow',        0.5); % Changing the relative flow of the 2nd Relative Flow.
        set(Rel_Flows{3}, 'AttValue', 'VehType',        1002);
        set(Rel_Flows{3}, 'AttValue', 'RelFlow',        0.001)
        set(Rel_Flows{4}, 'AttValue', 'VehType',        1003);
        set(Rel_Flows{4}, 'AttValue', 'RelFlow',        0.001)
        
        for flou = 1:3
            if flou == 1
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 800; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 61 : 70
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 94);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ3(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ3(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 2
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1200; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 71 : 80
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 378);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ3(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ3(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 3
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1600; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 81 : 90
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 933);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ3(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ3(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end
        end
    end
    
%next
    
    if typecek == 4
        Veh_composition_number = 1;
        Rel_Flows = Vissim.Net.VehicleCompositions.ItemByKey(Veh_composition_number).VehCompRelFlows.GetAll;
        set(Rel_Flows{1}, 'AttValue', 'VehType',        100); % Changing the vehicle type
        set(Rel_Flows{1}, 'AttValue', 'RelFlow',        0.25); % Changing the relative flow
        set(Rel_Flows{2}, 'AttValue', 'VehType',        1001);
        set(Rel_Flows{2}, 'AttValue', 'RelFlow',        0.75); % Changing the relative flow of the 2nd Relative Flow.
        set(Rel_Flows{3}, 'AttValue', 'VehType',        1002);
        set(Rel_Flows{3}, 'AttValue', 'RelFlow',        0.001)
        set(Rel_Flows{4}, 'AttValue', 'VehType',        1003);
        set(Rel_Flows{4}, 'AttValue', 'RelFlow',        0.001)
        
        for flou = 1:3
            if flou == 1
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 800; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 91 : 100
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 123);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ4(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ4(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 2
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1200; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 101 : 110
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 353);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ4(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ4(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 3
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1600; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 111 : 120
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 373);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ4(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ4(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end
        end
    end
    
%next
    
    if typecek == 5
        Veh_composition_number = 1;
        Rel_Flows = Vissim.Net.VehicleCompositions.ItemByKey(Veh_composition_number).VehCompRelFlows.GetAll;
        set(Rel_Flows{1}, 'AttValue', 'VehType',        100); % Changing the vehicle type
        set(Rel_Flows{1}, 'AttValue', 'RelFlow',        0.001); % Changing the relative flow
        set(Rel_Flows{2}, 'AttValue', 'VehType',        1001);
        set(Rel_Flows{2}, 'AttValue', 'RelFlow',        1); % Changing the relative flow of the 2nd Relative Flow.
        set(Rel_Flows{3}, 'AttValue', 'VehType',        1002);
        set(Rel_Flows{3}, 'AttValue', 'RelFlow',        0.001)
        set(Rel_Flows{4}, 'AttValue', 'VehType',        1003);
        set(Rel_Flows{4}, 'AttValue', 'RelFlow',        0.001)
        
        for flou = 1:3
            if flou == 1
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 800; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 121 : 130
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 253);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ5(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ5(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 2
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1200; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 131 : 140
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 700);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ5(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ5(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end

            if flou == 3
                VI_number   = 1; % VI = Vehicle Input
                VI_number_ramp   = 2; % VI = Vehicle Input
                new_volume  = 1600; % vehicles per hour
                new_volume_ramp  = 0.4*new_volume; % vehicles per hour
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number), 'AttValue', 'Volume(1)', new_volume);
                set(Vissim.Net.VehicleInputs.ItemByKey(VI_number_ramp), 'AttValue', 'Volume(1)', new_volume_ramp);
                for cnt_Sim = 141 : 150
                    set(Vissim.Simulation, 'AttValue', 'RandSeed', cnt_Sim);
                    set(Vissim.Simulation, 'AttValue', 'RandSeedIncr', 400);
                    Vissim.Simulation.RunContinuous;
                    Veh_TTT_measurement = Vissim.Net.VehicleNetworkPerformanceMeasurement; 
                    TTTmat_all(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_all(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    TTTmat_typ5(cnt_Sim,flou) = [Veh_TTT_measurement.get('AttValue', 'TravTmTot(Current,Last,All)')];
                    SpeedAvgmat_typ5(cnt_Sim,flou) = [get(Veh_TTT_measurement, 'AttValue', 'SpeedAvg(Current,Last,All)')];
                    for DC_measurement_number = 200:100:600
                        DC_measurement = Vissim.Net.DataCollectionMeasurements.ItemByKey(DC_measurement_number);
                        
                        if DC_measurement_number == 200
                            Vehs_det200(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 300
                            Vehs_det300(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 400
                            Vehs_det400(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 500
                            Vehs_det500(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        if DC_measurement_number == 600
                            Vehs_det600(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        end
                        
                        Vehs_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'Vehs(Current,Last,All)'); % No of vehicles in simulation in curr interval
                        Occup_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'OccupRate(Current,Last,All)'); % Occupancy
                        Arith_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgArith(Current,Last,All)'); % Avg Artihmetic Speed of vehicles
                        Harm_Speed_all(cnt_Sim,flou) = get(DC_measurement, 'AttValue', 'SpeedAvgHarm(Current,Last,All)'); % Avg Harmonic Speed of vehicles
                    end
                end
            end
        end
    end

end
Vissim.ResumeUpdateGUI; % allow updating of the complete Vissim workspace (network editor, list, chart and signal time table windows)
set(Vissim.Graphics.CurrentNetworkWindow, 'AttValue', 'QuickMode', 0) % deactivate QuickMode

%% number of simulations performed

% List of all Simulation runs:
Attributes      = {'No'; 'Timestamp'; 'RandSeed'; 'SimEnd'};
List_Sim_Runs = Vissim.Net.SimulationRuns.GetMultipleAttributes(Attributes);
disp(List_Sim_Runs) % show the List

%% ========================================================================
% End Vissim
%==========================================================================
Vissim.release