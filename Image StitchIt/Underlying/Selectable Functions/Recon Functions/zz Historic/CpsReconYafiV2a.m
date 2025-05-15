%==================================================================
% (V2a)
%   
%==================================================================

classdef CpsReconYafiV2a < handle

properties (SetAccess = private)                   
    Recon
    ReturnType
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsReconYafiV2a()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj,DATA)     
    [Image,err] = obj.Recon.CreateImage(DATA);
    
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    Panel(3,:) = {'Mean1',obj.Recon.Mean1,'Output'};
    Panel(4,:) = {'Mean2',obj.Recon.Mean2,'Output'};
    Panel(5,:) = {'Ratio',obj.Recon.Ratio,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'ReconYafiV2a';
    if obj.ReturnType == 0
        DispWid = [0.5 1.5];
        IMG = AddCompassMapInfo(Image,DATA{1}.DataObj,obj.Recon.AcqInfo{1},obj,PanelOutput,NameSuffix,DispWid);  
    else
        IMG = AddCompassInfo(Image,DATA{1}.DataObj,obj.Recon.AcqInfo{1},obj,PanelOutput,NameSuffix);
    end
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Reconipt)    
    obj.Recon = ReconYafiV2a();   
    obj.Recon.SetBaseMatrix(str2double(Reconipt.('BaseMatrix')));
    if strcmp(Reconipt.('ReturnType'),'RelB1')
        obj.Recon.SetReturnType(0);
        obj.ReturnType = 0;
    elseif strcmp(Reconipt.('ReturnType'),'All')
        obj.Recon.SetReturnType(1);
        obj.ReturnType = 1;
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
    obj.Recon.SetAcqInfo(Reconipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCH);
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
    mat = (10:10:700).';
    Interface{m,1}.options = mat2cell(mat,length(mat));
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'ReturnType';
    Interface{m,1}.entrystr = 'RelB1';
    Interface{m,1}.options = {'RelB1','All'}; 
end 

end
end