%==================================================================
% (v2a)
%   - 
%==================================================================

classdef StitchItRecon_ReturnChannels_v2a < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_ReturnChannels_v2a'
    BaseMatrix
    Fov2Return
    AcqInfo
    ReconNumber
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_ReturnChannels_v2a()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    RECON.Fov2Return = RECONipt.('Fov2Return');
    RECON.ReconNumber = str2double(RECONipt.('ReconNumber'));
    
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

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
    end  
    
    %% Return Channels
    DisplayStatusCompass('Return Channels',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnAllData(RECON.AcqInfo{RECON.ReconNumber});             % Do scaling inside here...

    DisplayStatusCompass('RxChannels: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfo{RECON.ReconNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    
    DisplayStatusCompass('RxIms: Generate',3);
    Image = StitchIt.CreateImage(Data);

    %% Testing Weighting 
%     for n = 1:RxChannels
%         AbsImage = abs(Image(:,:,:,n));
%         test(n) = max(AbsImage(:));
%         Image(:,:,:,n) = Image(:,:,:,n)/test(n);
%     end
%     SosImage = sum(abs(Image).^2,4);
%     Image = cat(4,Image,SosImage);   
%     RootSosImage = sqrt(SosImage);
%     Image = cat(4,Image,RootSosImage);     
    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    Panel(3,:) = {'Fov2Return',RECON.Fov2Return,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'RetChan';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfo{RECON.ReconNumber},StitchIt,PanelOutput,NameSuffix);
    clear StitchIt
    
end

end
end