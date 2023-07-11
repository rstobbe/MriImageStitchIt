%==================================================================
% (v2a)
%   - 
%==================================================================

classdef StitchItRecon_ReturnRxIms_v2a < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_ReturnRxIms_v2a'
    BaseMatrix
    Fov2Return
    AcqInfoRxp
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_ReturnRxIms_v2a()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    RECON.Fov2Return = RECONipt.('Fov2Return');
    
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

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
    end  
    
    %% RxIms
    DisplayStatusCompass('RxIms',2);
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnAllData(RECON.AcqInfoRxp);             % Do scaling inside here...

    DisplayStatusCompass('RxIms: Initialize',3);
    StitchIt = StitchItReturnRxIms(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoRxp,RxChannels); 

    DisplayStatusCompass('RxIms: Generate',3);
    Image = StitchIt.CreateImage(Data);

    %% SumOfSquares Profile
    % SumRxProfs = RxProfs .* conj(RxProfs);
    SosRxIms = sum(abs(Image).^2,4);
    Image = cat(4,Image,SosRxIms);    
    RootSosRxImage = sqrt(SosRxIms);
    Image = cat(4,Image,RootSosRxImage); 

    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    Panel(3,:) = {'Fov2Return',RECON.Fov2Return,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'RetRxIms';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfoRxp,StitchIt,PanelOutput,NameSuffix);
    clear StitchIt
    
end

end
end