%==================================================================
% (v2a)
%   - 
%==================================================================

classdef StitchItRecon_OffResMap_v2a < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_OffResMap_v2a'
    BaseMatrix
    Fov2Return
    AcqInfo
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_OffResMap_v2a()              
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
    RECON.AcqInfo = RECONipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCH;           
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
%         if RECON.AcqInfo{1}.NumTraj ~= DataObj.AcqsPerImage
%             err.flag = 1;
%             err.msg = 'Data and Recon do not match';
%             return
%         end
        if ~strcmp(RECON.AcqInfo{1}.name,DataObj.DataInfo.TrajName)
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

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
    end 
    
    %% Create Off Resonance Map
    DisplayStatusCompass('Off Resonance Map',2);
    ReconNumber = 1;
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSet(RECON.AcqInfo{ReconNumber},ReconNumber);             
    DisplayStatusCompass('Image1: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfo{ReconNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Image1: Generate',3);
    Image1 = StitchIt.CreateImage(Data);
    
    ReconNumber = 2;
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSet(RECON.AcqInfo{ReconNumber},ReconNumber);              
    DisplayStatusCompass('Image2: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfo{ReconNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Image2: Generate',3);
    Image2 = StitchIt.CreateImage(Data);
    
    TimeDiff = (RECON.AcqInfo{2}.SampStartTime - RECON.AcqInfo{1}.SampStartTime)/1000;
    OffResMap0 = (angle(Image2)-angle(Image1))/(2*pi*TimeDiff);
    MaxFreq = 0.5/TimeDiff;
    OffResMap0(OffResMap0 < -MaxFreq) = 1/TimeDiff + OffResMap0(OffResMap0 < -MaxFreq);
    OffResMap0(OffResMap0 > MaxFreq) = OffResMap0(OffResMap0 > MaxFreq) - 1/TimeDiff;
    
    SqImage = (abs(Image1)).^2;
    MaxSqImage = max(SqImage,[],[1 2 3]);
    SqImage(SqImage < 0.001*MaxSqImage) = 0;
    SumSqImage = sum(SqImage,4);
    SumSqImage(SumSqImage == 0) = 1;
    OffResMap(:,:,:,5) = sum((OffResMap0 .* SqImage),4)./SumSqImage;
    if sum(isnan(OffResMap(:))) > 0
        error('Nan problem');
    end
%     SumSqImage = sum((abs(Image1)).^2,4);
%     OffResMap(SumSqImage < 0.02*max(SumSqImage(:))) = 0;
    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    Panel(3,:) = {'Fov2Return',RECON.Fov2Return,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'OffResMap';
    IMG = AddCompassInfo(OffResMap,DataObj,RECON.AcqInfo{ReconNumber},StitchIt,PanelOutput,NameSuffix);
    clear StitchIt
    
end

end
end