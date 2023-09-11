%==================================================================
% (v2b)
%   - As StitchItRecon_SuperRegridOffResLoadMap_v2b
%==================================================================

classdef StitchItRecon_SuperRegridOffRes_v2b < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_SuperRegridOffRes_v2b'
    BaseMatrix
    PreScaleRxChans
    AcqInfo
    AcqInfoRxp
    AcqInfoOffRes
    ReconNumber
    Rcvrs
    RxProfSel
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_SuperRegridOffRes_v2b()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    RECON.ReconNumber = str2double(RECONipt.('ReconNumber'));
    RECON.PreScaleRxChans = RECONipt.('PreScaleRxChans');
    RECON.RxProfSel = RECONipt.('RxProfs');
    
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
    RECON.AcqInfoOffRes = RECONipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCHOR;    
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
        Data = DataObj.ReturnDataSet(RECON.AcqInfo{RECON.ReconNumber},RECON.ReconNumber);     
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
    if strcmp(RECON.RxProfSel,'Generated') 
        DisplayStatusCompass('RxProfs',2);
        DisplayStatusCompass('Load Data',3);
        Data = DataObj.ReturnDataSet(RECON.AcqInfoRxp,[]);     
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
    elseif strcmp(RECON.RxProfSel,'Actual') 
        RcvrSos = sum(abs(RECON.Rcvrs).^2,4);
        RxProfs = RECON.Rcvrs./sqrt(RcvrSos);
    end

    %% Create Off Resonance Map
    DisplayStatusCompass('Off Resonance Map',2);
    OffResImageNumber = 1;
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSet(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);             
    DisplayStatusCompass('Image1: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Image1: Generate',3);
    Image1 = StitchIt.CreateImage(Data);
    
    OffResImageNumber = 2;
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSet(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);              
    DisplayStatusCompass('Image2: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Image2: Generate',3);
    Image2 = StitchIt.CreateImage(Data);
    
    TimeDiff = (RECON.AcqInfoOffRes{2}.SampStartTime - RECON.AcqInfoOffRes{1}.SampStartTime)/1000;
    OffResMap0 = (angle(Image2)-angle(Image1))/(2*pi*TimeDiff);
    MaxFreq = 0.5/TimeDiff;
    OffResMap0(OffResMap0 < -MaxFreq) = 1/TimeDiff + OffResMap0(OffResMap0 < -MaxFreq);
    OffResMap0(OffResMap0 > MaxFreq) = OffResMap0(OffResMap0 > MaxFreq) - 1/TimeDiff;
    
    SqImage = (abs(Image1)).^2;
    MaxSqImage = max(SqImage,[],[1 2 3]);
    SqImage(SqImage < 0.001*MaxSqImage) = 0;
    SumSqImage = sum(SqImage,4);
    SumSqImage(SumSqImage == 0) = 1;
    OffResMap = sum((OffResMap0 .* SqImage),4)./SumSqImage;
    if sum(isnan(OffResMap(:))) > 0
        error('Nan problem');
    end
    %---
    % OffResMap = OffResMap/1e6;            % No map test
    %---    
    
    %% Sampling Timing
%     OffResTimeArr = DataObj.FirstSampDelay + RECON.AcqInfo{RECON.ReconNumber}.OffResTimeArr;          % Doesn't work - come back to this
    OffResTimeArr = RECON.AcqInfo{RECON.ReconNumber}.OffResTimeArr;
    
    %% Image
    DisplayStatusCompass('Super Recon',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSet(RECON.AcqInfo{RECON.ReconNumber},RECON.ReconNumber); 
    for n = 1:DataObj.RxChannels
        Data(:,:,n) = Data(:,:,n)/Scale(n);
    end 
    DisplayStatusCompass('Super Recon: Initialize',3);
    StitchIt = StitchItSuperRegridInputRxProfOffRes(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},DataObj.RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Super Recon: Generate',3);
    Image = StitchIt.CreateImage(Data,RxProfs,OffResMap,OffResTimeArr);
    clear StichIt
    %---    
%    Image(:,:,:,2) = OffResMap;
    %---
    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'SuperRegridOffResCor';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfo{RECON.ReconNumber},StitchIt,PanelOutput,NameSuffix);
    
end

end
end