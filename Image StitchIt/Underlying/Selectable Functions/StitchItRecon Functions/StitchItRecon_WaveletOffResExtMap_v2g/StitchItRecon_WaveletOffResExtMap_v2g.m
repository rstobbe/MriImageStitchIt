%==================================================================
% (v2g)
%   - From:  StitchItRecon_WaveletOffRes_v2g
%==================================================================

classdef StitchItRecon_WaveletOffResExtMap_v2g < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_WaveletOffResExtMap_v2g'
    BaseMatrix
    Fov2Return
    AcqInfo
    AcqInfoRxp
    OffResMap
    ReconNumber
    LevelsPerDim
    NumIterations
    Lambda
    Rcvrs
    MaxEig
    DisplayResult
    PreScaleRxChans
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_WaveletOffResExtMap_v2g()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    RECON.ReconNumber = str2double(RECONipt.('ReconNumber'));
    RECON.NumIterations = str2double(RECONipt.('NumIterations'));
    RECON.PreScaleRxChans = RECONipt.('PreScaleRxChans');
    if not(isempty(RECONipt.('MaxEig')))
        RECON.MaxEig = str2double(RECONipt.('MaxEig'));
    end
    RECON.DisplayResult = RECONipt.('DisplayResult');
    
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
    RECON.OffResMap = single(RECONipt.([CallingLabel,'_Data']).('OffResMap_File_Data').IMG.Im);     
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
    if ~strcmp(RECON.AcqInfo{RECON.ReconNumber}.name,DataObj.DataInfo.TrajName)
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
    
    %% PreScaleRxChans
    if not(strcmp(RECON.PreScaleRxChans,'No'))
        DisplayStatusCompass('PreScaleRxChans',2);
        DisplayStatusCompass('Load Data',3);
        Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfo{RECON.ReconNumber},RECON.ReconNumber);             
        DisplayStatusCompass('PreScaleRxChans: Initialize',3);
        StitchIt = StitchItReturnChannels(); 
        StitchIt.SetBaseMatrix(RECON.BaseMatrix);
        StitchIt.SetFov2ReturnBaseMatrix;
        StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},DataObj.RxChannels); 
        DisplayStatusCompass('PreScaleRxChans: Generate',3);
        Image = StitchIt.CreateImage(Data);
        clear StichIt
        for n = 1:DataObj.RxChannels
            AbsImage = abs(Image(:,:,:,n));
            Scale(n) = max(AbsImage(:));
        end  
    end

    %% Weight Coils
    if strcmp(RECON.PreScaleRxChans,'Linear')
        Scale = Scale/mean(Scale);
    elseif strcmp(RECON.PreScaleRxChans,'Root')
        Scale = Scale/mean(Scale);
	    Scale = sqrt(Scale);
    elseif strcmp(RECON.PreScaleRxChans,'ReduceHotLinear')
        Scale0 = ones(1,DataObj.RxChannels);
        Scale0(Scale > mean(Scale)) = Scale(Scale > mean(Scale))/mean(Scale);
        Scale = Scale0/mean(Scale0);
    elseif strcmp(RECON.PreScaleRxChans,'ReduceHotRoot')
        Scale0 = ones(1,DataObj.RxChannels);
        Scale0(Scale > mean(Scale)) = sqrt(Scale(Scale > mean(Scale))/mean(Scale));
        Scale = Scale0/mean(Scale0);
    else
        Scale = ones(1,DataObj.RxChannels);
    end 
    
    %% RxProfs
    DisplayStatusCompass('RxProfs',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfoRxp,[]);
    for n = 1:DataObj.RxChannels
        Data(:,:,n) = Data(:,:,n)/Scale(n);
    end 
    DisplayStatusCompass('RxProfs: Initialize',3);
    StitchIt = StitchItReturnRxProfs();
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    StitchIt.Initialize(RECON.AcqInfoRxp,DataObj.RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('RxProfs: Generate',3);
    RxProfs = StitchIt.CreateImage(Data);
    clear SitchIt
    if RECON.DisplayResult
        totgblnum = ImportImageCompass(RxProfs,'RxProfs');
        Gbl2ImageOrtho('IM3',totgblnum);
    end

    %% Interpolate
    DisplayStatusCompass('Off Resonance Map',2);
    DisplayStatusCompass('Interpolate',3);
    sz = size(RECON.OffResMap);
    OffResBaseMatrix = sz(1);
    Array = linspace((OffResBaseMatrix/RECON.BaseMatrix)/2,OffResBaseMatrix-(OffResBaseMatrix/RECON.BaseMatrix)/2,RECON.BaseMatrix) + 0.5;
    [X,Y,Z] = meshgrid(Array,Array,Array);
    OffResMapInt = interp3(RECON.OffResMap,X,Y,Z,'maximak');
    %OffResMapInt = interp3(RECON.OffResMap,X,Y,Z,'cubic');
    %OffResMapInt = interp3(RECON.OffResMap,X,Y,Z,'linear');
    if RECON.DisplayResult
        totgblnum = ImportOffResMapCompass(OffResMapInt,'OffResMapInt',[],[],max(abs(RECON.OffResMap(:))));
        Gbl2ImageOrtho('IM3',totgblnum);
    end

    %% Sampling Timing
    OffResTimeArr = RECON.AcqInfo{RECON.ReconNumber}.OffResTimeArr;  
    
    %% Initial Image
    DisplayStatusCompass('Initial Image',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfo{RECON.ReconNumber},RECON.ReconNumber);
    for n = 1:DataObj.RxChannels
        Data(:,:,n) = Data(:,:,n)/Scale(n);
    end 
    DisplayStatusCompass('Initial Image: Initialize',3);
    StitchIt = StitchItSuperRegridInputRxProfOffRes(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},DataObj.RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Initial Image: Generate',3);
    Image0 = StitchIt.CreateImage(Data,RxProfs,OffResMapInt,OffResTimeArr);
    clear StichIt    
    if RECON.DisplayResult
        totgblnum = ImportImageCompass(Image0,'Image0');
        Gbl2ImageOrtho('IM3',totgblnum);
    end

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
    end    
%     gpuDevice(3);       % Don't do this!  Needs to stay as the last one!  
    
    %% Wavelet 
    DisplayStatusCompass('Iterate Image',2);    
    DisplayStatusCompass('Iterate Image: Initialize',3);
    StitchIt = StitchItWaveletOffRes(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetLevelsPerDim(RECON.LevelsPerDim);
    StitchIt.SetNumIterations(RECON.NumIterations);
    StitchIt.SetLambda(RECON.Lambda);
    StitchIt.SetFov2ReturnBaseMatrix;
    StitchIt.SetMaxEig(RECON.MaxEig);
    StitchIt.SetDisplayResultOn;
    StitchIt.SetDisplayIterationStep(10);
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},RxChannels); 
    DisplayStatusCompass('Iterate Image: Generate',3);
    Image = StitchIt.CreateImage(Data,RxProfs,OffResMapInt,OffResTimeArr,Image0); 
    AbsMaxEig = abs(StitchIt.MaxEig);
    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    Panel(3,:) = {'LevelsPerDim',RECON.LevelsPerDim,'Output'};
    Panel(4,:) = {'NumIterations',RECON.NumIterations,'Output'};
    Panel(5,:) = {'Lambda',RECON.Lambda,'Output'};
    Panel(6,:) = {'PreScaleRxChans',RECON.PreScaleRxChans,'Output'};
    Panel(7,:) = {'AbsMaxEig',AbsMaxEig,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    NameSuffix = 'WaveletOffRes';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfo{RECON.ReconNumber},StitchIt,PanelOutput,NameSuffix);
    clear StitchIt
    
end

end
end