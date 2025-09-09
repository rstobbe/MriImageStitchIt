%==================================================================
% (v2a)
%   - 
%==================================================================

classdef StitchItRecon_Wavelet_v2a < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_Wavelet_v2a'
    BaseMatrix
    Fov2Return
    AcqInfo
    AcqInfoRxp
    ReconNumber
    LevelsPerDim
    NumIterations
    Lambda
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_Wavelet_v2a()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    RECON.Fov2Return = RECONipt.('Fov2Return');
    RECON.ReconNumber = str2double(RECONipt.('ReconNumber'));
    RECON.NumIterations = str2double(RECONipt.('NumIterations'));
    LevelsPerDim0 = RECONipt.('LevelsPerDim');
    for n = 1:3
        RECON.LevelsPerDim(n) = str2double(LevelsPerDim0(n));
    end
    RECON.Lambda = str2double(RECONipt.('Lambda'));
    
    CallingLabel = RECONipt.Struct.labelstr;
    if not(isfield(RECONipt,[CallingLabel,'_Data']))
        if isfield(RECONipt.('Recon_File').Struct,'selectedfile')
            file = RECONipt.('Recon_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Recon_File';
                ErrDisp(err);
                return
            else
                load(file);
                RECONipt.([CallingLabel,'_Data']).('Recon_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Recon_File';
            ErrDisp(err);
            return
        end
    end
    RECON.AcqInfo = RECONipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCH;
    RECON.AcqInfoRxp = RECONipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCHRXP;       
end

%==================================================================
% SetBaseMatrix
%==================================================================  
function SetBaseMatrix(RECON,val)    
    RECON.BaseMatrix = val;
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(RECON,DataObj)     
    %% Test  
    err.flag = 0;
    IMG = [];
    if isprop(DataObj,'AcqsPerImage')
        if RECON.AcqInfoRxp.NumTraj ~= DataObj.AcqsPerImage
            err.flag = 1;
            err.msg = 'Data and Recon do not match';
            return
        end
        if ~strcmp(RECON.AcqInfoRxp.name,DataObj.DataInfo.TrajName)
            answer = questdlg('Data and Recon have different names - continue?');
            switch answer
                case 'No'
                    err.flag = 1;
                    err.msg = 'Data and Recon do not match';
                    return
                case 'Cancel'
                    err.flag = 1;
                    err.msg = 'Data and Recon do not match';
                    return
            end
        end
    end
    if RECON.ReconNumber ~= length(RECON.AcqInfo)
        err.flag = 1;
        err.msg = 'ReconNumber beyond length Recon_File';
        return
    end

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
    end
    
    %% RxProfs
    DisplayStatusCompass('RxProfs',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnAllData(RECON.AcqInfoRxp);             % Do scaling inside here...
    
    DisplayStatusCompass('RxProfs: Initialize',3);
    StitchIt = StitchItReturnRxProfs();
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoRxp,RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    
    DisplayStatusCompass('RxProfs: Generate',3);
    RxProfs = StitchIt.CreateImage(Data);
    
    %% Image
    DisplayStatusCompass('Initial Image',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnAllData(RECON.AcqInfo{RECON.ReconNumber});             % Do scaling inside here...
    
    DisplayStatusCompass('Initial Image: Initialize',3);
    StitchIt = StitchItSuperRegridInputRxProf(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);

    DisplayStatusCompass('Initial Image: Generate',3);
    Image0 = StitchIt.CreateImage(Data,RxProfs);
    clear SitchIt
    
    %% Wavelet 
    DisplayStatusCompass('CompSense Image',2);    
    DisplayStatusCompass('CompSense Image: Initialize',3);
    StitchIt = StitchItWaveletInputRxProfIm0(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetLevelsPerDim(RECON.LevelsPerDim);
    StitchIt.SetNumIterations(RECON.NumIterations);
    StitchIt.SetLambda(RECON.Lambda);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},RxChannels); 

    DisplayStatusCompass('CompSense Image: Generate',3);
    Image = StitchIt.CreateImage(Data,RxProfs,Image0);
    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    Panel(3,:) = {'Fov2Return',RECON.Fov2Return,'Output'};
    Panel(4,:) = {'LevelsPerDim',RECON.LevelsPerDim,'Output'};
    Panel(5,:) = {'NumIterations',RECON.NumIterations,'Output'};
    Panel(6,:) = {'Lambda',RECON.Lambda,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    NameSuffix = 'Wavelet';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfo{RECON.ReconNumber},StitchIt,PanelOutput,NameSuffix);
    clear StitchIt
    
end

end
end