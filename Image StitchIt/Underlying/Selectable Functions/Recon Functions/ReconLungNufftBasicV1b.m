%==================================================================
% (V1b)
%   - include RespPhase selection
%==================================================================

classdef ReconLungNufftBasicV1b < handle

properties (SetAccess = private)                   
    Recon
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = ReconLungNufftBasicV1b()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj,DATA)     
    [Image,err] = obj.Recon.CreateImage(DATA);
    
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    Panel(3,:) = {'OffResCorrection','No','Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'NufftBasic';
    IMG = AddCompassInfo(Image,DATA{1}.DataObj,obj.Recon.AcqInfo{obj.Recon.ReconNumber},obj,PanelOutput,NameSuffix);         
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Reconipt)    
    obj.Recon = ReconLungNufftV1b();   
    obj.Recon.SetBaseMatrix(str2double(Reconipt.('BaseMatrix')));
    obj.Recon.SetReconNumber(1);        % No dual-echo 
    ReconRespPhase = Reconipt.('ReconRespPhase');
    if strcmp(ReconRespPhase,'all') || strcmp(ReconRespPhase,'All')
        Vals = 1:20;
    else
        inds = strfind(ReconRespPhase,':');
        if isempty(inds)
            Vals = str2double(ReconRespPhase);
        else
            Start = str2double(ReconRespPhase(1:inds(1)-1));
            Step = str2double(ReconRespPhase(inds(1)+1:inds(2)-1));
            Stop = str2double(ReconRespPhase(inds(2)+1:end));
            Vals = (Start:Step:Stop);
        end
    end
    obj.Recon.SetRespPhaseImages2Do(Vals);     
    obj.Recon.SetOffResCorrection(0);
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
    mat = (10:10:500).';
    Interface{m,1}.options = mat2cell(mat,length(mat));
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'ReconRespPhase (/20)';
    Interface{m,1}.entrystr = '11';
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