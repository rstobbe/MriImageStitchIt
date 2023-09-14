%==================================================================
% (v2c)
%   - Iterate
%==================================================================

classdef StitchItRecon_ReturnOffResMap_v2c < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_ReturnOffResMap_v2c'
    BaseMatrix
    AcqInfoOffRes
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_ReturnOffResMap_v2c()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    
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
    if ~strcmp(RECON.AcqInfoOffRes{1}.name,DataObj.DataInfo.TrajName)
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

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
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
    OffResMap = (angle(Image2)-angle(Image1))/(2*pi*TimeDiff);
    MaxFreq = 0.5/TimeDiff;
    OffResMap(OffResMap < -MaxFreq) = 1/TimeDiff + OffResMap(OffResMap < -MaxFreq);
    OffResMap(OffResMap > MaxFreq) = OffResMap(OffResMap > MaxFreq) - 1/TimeDiff;
    
    SqImage = (abs(Image1)).^2;
    MaxSqImage = max(SqImage,[],[1 2 3]);
    SqImage(SqImage < 0.001*MaxSqImage) = 0;
    SumSqImage = sum(SqImage,4);
    SumSqImage(SumSqImage == 0) = 1;
    OffResMap = sum((OffResMap .* SqImage),4)./SumSqImage;
    if sum(isnan(OffResMap(:))) > 0
        error('Nan problem');
    end
    Image(:,:,:,1) = OffResMap;
    Image(:,:,:,9) = SumSqImage; 
    
    %% Sampling Timing
%     OffResTimeArr = DataObj.FirstSampDelay + RECON.AcqInfo{RECON.ReconNumber}.OffResTimeArr;          % Doesn't work - come back to this
    OffResTimeArr = RECON.AcqInfoOffRes{1}.OffResTimeArr;    
    
    %% Create Off Resonance Map
    ItNum = 2;
    for n = 2:ItNum
        DisplayStatusCompass('Off Resonance Map',2);
        OffResImageNumber = 1;
        DisplayStatusCompass('Load Data',3);
        Data = DataObj.ReturnDataSet(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);             
        DisplayStatusCompass('Image1: Initialize',3);
        StitchIt = StitchItReturnChannelsOffRes(); 
        StitchIt.SetBaseMatrix(RECON.BaseMatrix);
        StitchIt.SetFov2ReturnBaseMatrix;
        RxChannels = DataObj.RxChannels;
        StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
        Data = DataObj.ScaleData(StitchIt,Data);
        DisplayStatusCompass('Image1: Generate',3);
        Image1 = StitchIt.CreateImage(Data,OffResMap,OffResTimeArr);

        OffResImageNumber = 2;
        DisplayStatusCompass('Load Data',3);
        Data = DataObj.ReturnDataSet(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);              
        DisplayStatusCompass('Image2: Initialize',3);
        StitchIt = StitchItReturnChannelsOffRes();  
        StitchIt.SetBaseMatrix(RECON.BaseMatrix);
        StitchIt.SetFov2ReturnBaseMatrix;
        RxChannels = DataObj.RxChannels;
        StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
        Data = DataObj.ScaleData(StitchIt,Data);
        DisplayStatusCompass('Image2: Generate',3);
        Image2 = StitchIt.CreateImage(Data,OffResMap,OffResTimeArr);

        TimeDiff = (RECON.AcqInfoOffRes{2}.SampStartTime - RECON.AcqInfoOffRes{1}.SampStartTime)/1000;
        OffResMap = (angle(Image2)-angle(Image1))/(2*pi*TimeDiff);
        MaxFreq = 0.5/TimeDiff;
        OffResMap(OffResMap < -MaxFreq) = 1/TimeDiff + OffResMap(OffResMap < -MaxFreq);
        OffResMap(OffResMap > MaxFreq) = OffResMap(OffResMap > MaxFreq) - 1/TimeDiff;

        SqImage = (abs(Image1)).^2;
        MaxSqImage = max(SqImage,[],[1 2 3]);
        SqImage(SqImage < 0.001*MaxSqImage) = 0;
        SumSqImage = sum(SqImage,4);
        SumSqImage(SumSqImage == 0) = 1;
        OffResMap = sum((OffResMap .* SqImage),4)./SumSqImage;
        if sum(isnan(OffResMap(:))) > 0
            error('Nan problem');
        end
        Image(:,:,:,n) = OffResMap;
    end

    %% Image
        Image(:,:,:,10) = SumSqImage; 
    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'OffResMap';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfoOffRes{1},StitchIt,PanelOutput,NameSuffix);
    
end

end
end