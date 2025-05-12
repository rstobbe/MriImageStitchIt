%==================================================================
% (V2a)
%   - 
%==================================================================

classdef CpsReconYvfaFbV2a < handle

properties (SetAccess = private)                   
    Recon
    CpsTrajMashObj
    ReturnType
    Shift
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsReconYvfaFbV2a()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj,DATA)     
    [Image,err] = obj.Recon.CreateImage(DATA);
    %TrajMashPanel = obj.CpsTrajMashObj.ReturnInfoCompass();

    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconObj',obj.Recon.Method,'Output'};
    Panel(3,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    Panel(4,:) = {'Shift',obj.Shift,'Output'};
    Panel(5,:) = {'','','Output'};
    %Panel = cat(1,Panel,TrajMashPanel);
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'ReconYvfaFbV2a';
    IMG = AddCompassInfo(Image,DATA{1}.DataObj,obj.Recon.AcqInfo{1},obj,PanelOutput,NameSuffix);         
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,ReconIpt)    
    obj.Recon = ReconYvfaFbV2a();   
    obj.Recon.SetBaseMatrix(str2double(ReconIpt.('ReconMatrix')));
    if strcmp(ReconIpt.('ReturnType'),'RelB1')
        obj.Recon.SetReturnType(0);
        obj.ReturnType = 0;
    elseif strcmp(ReconIpt.('ReturnType'),'All')
        obj.Recon.SetReturnType(1);
        obj.ReturnType = 1;
    end   
    if not(strcmp(ReconIpt.('ReturnFov'),'Full'))
        obj.Recon.SetDoSaveSmallerFov(1);
        obj.Recon.SetSaveSmallerFov(str2double(ReconIpt.('ReturnFov')));
    end 
    obj.Shift(1) = str2double(ReconIpt.('ShiftLr'));
    obj.Shift(2) = str2double(ReconIpt.('ShiftTb'));
    obj.Shift(3) = str2double(ReconIpt.('ShiftIo'));
    obj.Recon.SetShift(obj.Shift);
    obj.Recon.SetMaskVal(str2double(ReconIpt.('MaskVal')));
    if strcmp(ReconIpt.('LowRamCase'),'Yes')
        obj.Recon.SetLowRamCase(1);
    end 
    if strcmp(ReconIpt.('LowGpuRamCase'),'Yes')
        obj.Recon.SetLowGpuRamCase(1);
    end 

    CallingLabel = ReconIpt.Struct.labelstr;
    if not(isfield(ReconIpt,[CallingLabel,'_Data']))
        if isfield(ReconIpt.('Recon_File').Struct,'selectedfile')
            file = ReconIpt.('Recon_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Recon_File';
                ErrDisp(err);
                return
            else
                load(file);
                ReconIpt.([CallingLabel,'_Data']).('Recon_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Recon_File';
            ErrDisp(err);
            return
        end
    end
    obj.Recon.SetAcqInfo(ReconIpt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCH);
    obj.Recon.SetAcqInfoRxp(ReconIpt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCHRXP);

    TrajMashfunc = ReconIpt.('TrajMashfunc').Func; 
    TrajMashIpt = ReconIpt.('TrajMashfunc');
    CallingFunction = ReconIpt.Struct.labelstr;
    if isfield(ReconIpt,([CallingFunction,'_Data']))
        if isfield(ReconIpt.([CallingFunction,'_Data']),('TrajMashfunc_Data'))
            TrajMashIpt.TrajMashfunc_Data = ReconIpt.([CallingFunction,'_Data']).TrajMashfunc_Data;
        end
    end
    obj.Recon.SetTrajMashInfo(TrajMashfunc,TrajMashIpt);
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    path = SCRPTPATHS.voyagerloc;
    func = 'CpsTrajMashBodyCoilEndExp2b';
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
    Interface{m,1}.labelstr = 'ReconMatrix';
    Interface{m,1}.entrystr = '300';
    mat = (10:10:500).';
    Interface{m,1}.options = mat2cell(mat,length(mat));
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'ReturnFov (mm)';
    Interface{m,1}.entrystr = 'Full';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'ReturnType';
    Interface{m,1}.entrystr = 'RelB1';
    Interface{m,1}.options = {'RelB1','All'}; 
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'MaskVal';
    Interface{m,1}.entrystr = '0.02';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'ShiftIo (mm)';
    Interface{m,1}.entrystr = '0';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'ShiftTb (mm)';
    Interface{m,1}.entrystr = '0';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'ShiftLr (mm)';
    Interface{m,1}.entrystr = '0';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'LowRamCase';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'LowGpuRamCase';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'ScrptFunc';
    Interface{m,1}.labelstr = 'TrajMashfunc';
    Interface{m,1}.entrystr = func;
    Interface{m,1}.searchpath = path;
    Interface{m,1}.path = [path,func];
end 

end
end