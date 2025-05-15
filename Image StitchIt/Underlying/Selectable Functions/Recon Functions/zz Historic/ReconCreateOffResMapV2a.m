%==================================================================
% (V2a)
%   
%==================================================================

classdef ReconCreateOffResMapV2a < handle

properties (SetAccess = private)                   
    Recon
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = ReconCreateOffResMapV2a()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj,DATA)     
    [OffResMap,err] = obj.Recon.CreateOffResMap(DATA);
    
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'OffResMap';
    IMG = AddCompassMapInfo(OffResMap,DATA{1}.DataObj,obj.Recon.AcqInfoOffRes{1},obj,PanelOutput,NameSuffix);
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Reconipt)    
    obj.Recon = ReconOffResMapV2a();   
    obj.Recon.SetBaseMatrix(str2double(Reconipt.('BaseMatrix')));
    obj.Recon.SetRelMaskVal(str2double(Reconipt.('RelMaskVal')));
    if strcmp(Reconipt.('DisplayRxProfs'),'Yes')
        obj.Recon.SetDisplayRxProfs(1);
    end 
    if strcmp(Reconipt.('DisplayInitialImages'),'Yes')
        obj.Recon.SetDisplayInitialImages(1);
    end 
    CallingLabel = Reconipt.Struct.labelstr;
    if not(isfield(Reconipt,[CallingLabel,'_Data']))
        if isfield(Reconipt.('Recon_File').Struct,'selectedfile')
            file = Reconipt.('Recon_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Recon_File';
                ErrDisp(err);
                return
            else
                load(file);
                Reconipt.([CallingLabel,'_Data']).('Recon_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Recon_File';
            ErrDisp(err);
            return
        end
    end
    obj.Recon.SetAcqInfoOffRes(Reconipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCHOR);
    obj.Recon.SetAcqInfoRxp(Reconipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCHRXP);
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    global COMPASSINFO
    m = 1;
    Interface{m,1}.entrytype = 'RunExtFunc';
    Interface{m,1}.labelstr = 'Recon_File';
    Interface{m,1}.entrystr = '';
    Interface{m,1}.buttonname = 'Load';
    Interface{m,1}.runfunc1 = 'LoadReconCur';
    Interface{m,1}.(Interface{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
    Interface{m,1}.runfunc2 = 'LoadReconDisp';
    Interface{m,1}.(Interface{m,1}.runfunc2).defloc = COMPASSINFO.USERGBL.trajreconloc;
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'BaseMatrix';
    Interface{m,1}.entrystr = 140;
    mat = (10:10:500).';
    Interface{m,1}.options = mat2cell(mat,length(mat));
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'RelMaskVal';
    Interface{m,1}.entrystr = '0.05';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DisplayRxProfs';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DisplayInitialImages';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
end 

end
end