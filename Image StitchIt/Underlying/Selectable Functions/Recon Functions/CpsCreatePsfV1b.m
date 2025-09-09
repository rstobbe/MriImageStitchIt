%==================================================================
% 
%   
%==================================================================

classdef CpsCreatePsfV1b < handle

properties (SetAccess = private)                   
    Recon
    Path
    Name
    AcqPanelOutput
    SubSamp
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsCreatePsfV1b()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj)     
    [Image,err] = obj.Recon.CreateImage();
    
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'Psf';
    DataObj.DataInfo.PanelOutput = obj.AcqPanelOutput;
    DataObj.DataInfo.ExpPars = '';
    DataObj.DataPath = obj.Path;
    DataObj.DataName = obj.Name;
    AcqInfo.Fov = obj.Recon.AcqInfo{obj.Recon.ReconNumber}.Fov*obj.SubSamp;
    IMG = AddCompassInfo(Image,DataObj,AcqInfo,obj,PanelOutput,NameSuffix);         
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Reconipt)    
    obj.Recon = CreatePsfV1b();   
    obj.Recon.SetBaseMatrix(str2double(Reconipt.('BaseMatrix')));
    obj.Recon.SetSubSamp(str2double(Reconipt.('SubSamp')));
    obj.SubSamp = str2double(Reconipt.('SubSamp'));
    %obj.Recon.SetReconNumber(1);        % No dual-echo 
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
    obj.Path = Reconipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.path;
    obj.Name = Reconipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.name;
    obj.AcqPanelOutput = Reconipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.PanelOutput;
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
    Interface{m,1}.labelstr = 'SubSamp';
    Interface{m,1}.entrystr = 2;
    Interface{m,1}.options = {2,2.5,3.2};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'BaseMatrix';
    Interface{m,1}.entrystr = 140;
    mat = (10:10:500).';
    Interface{m,1}.options = mat2cell(mat,length(mat));
end 

end
end