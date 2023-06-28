%==================================================================
% (v2a)
%   - 
%==================================================================

classdef StitchItRecon_ReturnRxProfs_v2a < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_ReturnRxProfs_v2a'
    BaseMatrix
    Fov2Return
    AcqInfoRxp
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_ReturnRxProfs_v2a()              
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

    err.flag = 0;
    StitchIt = StitchItReturnRxProfs(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    if strcmp(RECON.Fov2Return,'GridMatrix')
        StitchIt.SetFov2ReturnGridMatrix;
    else
        StitchIt.SetFov2ReturnBaseMatrix;
    end
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoRxp,RxChannels); 
    Data = DataObj.DataFull{1};                                     % Receive profile must be associated with the first data set
    Data = DataObj.ScaleSimulationData(StitchIt,Data);   
    Image = StitchIt.CreateImage(Data);
    
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    Panel(3,:) = {'Fov2Return',RECON.Fov2Return,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'RxProfs';
    IMG = AddCompassInfo(Image,DataObj,RECON.AcqInfoRxp,StitchIt,PanelOutput,NameSuffix);
    clear StitchIt
    
end

end
end