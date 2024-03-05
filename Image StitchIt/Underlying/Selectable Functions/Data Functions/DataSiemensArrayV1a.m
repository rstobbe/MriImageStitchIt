%==================================================================
% (V1a)
%   
%==================================================================

classdef DataSiemensArrayV1a < handle

properties (SetAccess = private)                   
    Recon
    NumFiles = 1
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = DataSiemensArrayV1a()              
end

%=================================================================
% InitViaCompass
%==================================================================  
function [SCRPTipt,SCRPTGBL,DATA,err] = InitViaCompass(obj,SCRPTipt,SCRPTGBL,DATAipt) 
    
    err.flag = 0;
    numfiles = str2double(DATAipt.('NumFiles').EntryStr);
    for n = 1:numfiles
        PanelLabel{n} = ['Data_File',num2str(n)];
    end
    CallingLabel = DATAipt.Struct.labelstr;
    for n = 1:numfiles  
        if not(isfield(DATAipt,[CallingLabel,'_Data']))
            if isfield(DATAipt.(PanelLabel{n}).Struct,'selectedfile')
                file = DATAipt.(PanelLabel{n}).Struct.selectedfile;
                if not(exist(file,'file'))
                    err.flag = 1;
                    err.msg = '(Re) Load Data_File';
                    ErrDisp(err);
                    return
                else
                    saveData.loc = file;
                    ind = strfind(file,'\');
                    saveData.file = file(ind(end)+1:end);
                    saveData.path = file(1:ind(end));
                    SCRPTGBL.RWSUI.funclabel = PanelLabel{n};
                    SCRPTGBL.RWSUI.callingfuncs{1} = 'StitchDatafunc';
                    [SCRPTipt,SCRPTGBL,err] = SelectSiemensDataExpStitchIt(SCRPTipt,SCRPTGBL,saveData);
                    if err.flag
                        ErrDisp(err);
                        return
                    end
                    DATA.DATA{1} = SCRPTGBL.([CallingLabel,'_Data']).([PanelLabel{n},'_Data']);
                end
            else
                err.flag = 1;
                err.msg = '(Re) Load Data_File';
                ErrDisp(err);
                return
            end
        else    
            DATA.DATA{n} = DATAipt.([CallingLabel,'_Data']).([PanelLabel{n},'_Data']);
        end
    end

end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    global MULTIFILELOAD
    m = 1;
    Interface{m,1}.entrytype = 'RunExtFunc';
    Interface{m,1}.labelstr = 'NumFiles';
    Interface{m,1}.entrystr = '1';
    Interface{m,1}.buttonname = 'Select';
    Interface{m,1}.runfunc1 = 'NumFileSel';
    Interface{m,1}.searchpath = SCRPTPATHS.scrptshareloc;
    Interface{m,1}.path = SCRPTPATHS.scrptshareloc;
    if isempty(MULTIFILELOAD)
        return
    end    
    global COMPASSINFO
    for n = 1:MULTIFILELOAD.numfiles
        m = m+1;
        Interface{m,1}.entrytype = 'RunExtFunc';
        Interface{m,1}.labelstr = ['Data_File',num2str(n)];
        Interface{m,1}.entrystr = '';
        Interface{m,1}.buttonname = 'Select';
        Interface{m,1}.runfunc1 = 'SelectSiemensDataCurStitchIt';
        Interface{m,1}.(Interface{m,1}.runfunc1).curloc = SCRPTPATHS.experimentsloc;
        Interface{m,1}.(Interface{m,1}.runfunc1).defloc = COMPASSINFO.USERGBL.tempdataloc;
        Interface{m,1}.runfunc2 = 'LoadSiemensDataDisp';
        Interface{m,1}.searchpath = SCRPTPATHS.scrptshareloc;
        Interface{m,1}.path = SCRPTPATHS.scrptshareloc;
    end
end 

%==================================================================
% NumFileSel
%==================================================================  
function [SCRPTipt,SCRPTGBL,err] = NumFileSel(obj,SCRPTPATHS,SCRPTGBL) 
    global MULTIFILELOAD
    Status2('busy','Multiple File Select',1);
    err.flag = 0;
    err.msg = '';
    answer = inputdlg('How Many Files?','Multiple File Select');
    if isempty(answer)
        err.flag = 4;
        err.msg = 'Return';
        return
    end
    MULTIFILELOAD.numfiles = str2double(answer{1});
    RWSUI = SCRPTGBL.RWSUI;
    PanelScriptUpdate_B9(RWSUI.curpanipt-1,RWSUI.tab,RWSUI.panelnum);
    SCRPTipt = LabelGet(RWSUI.tab,RWSUI.panelnum);
    SCRPTipt(SCRPTGBL.RWSUI.curpanipt).entrystr = num2str(MULTIFILELOAD.numfiles);
    SCRPTipt(SCRPTGBL.RWSUI.curpanipt).entrystruct.entrystr = num2str(MULTIFILELOAD.numfiles);
    SCRPTipt(SCRPTGBL.RWSUI.curpanipt).entrystruct.altval = 1;
    callingfuncs = SCRPTGBL.RWSUI.callingfuncs;
    if isfield(SCRPTGBL,[callingfuncs{1},'_Data'])
        DataArr = SCRPTGBL.([callingfuncs{1},'_Data']);
        for n = 1:MULTIFILELOAD.numfiles
            if isfield(DataArr,['Data_File',num2str(n),'_Data'])
                Data = DataArr.(['Data_File',num2str(n),'_Data']);
                SCRPTipt(SCRPTGBL.RWSUI.curpanipt+n).entrystr = Data.label;
                SCRPTipt(SCRPTGBL.RWSUI.curpanipt+n).entrystruct.entrystr = Data.label;
                SCRPTipt(SCRPTGBL.RWSUI.curpanipt+n).entrystruct.altval = 1;
                SCRPTipt(SCRPTGBL.RWSUI.curpanipt+n).entrystruct.selectedfile = Data.loc;
                SCRPTipt(SCRPTGBL.RWSUI.curpanipt+n).entrystruct.('SelectSiemensDataCurStitchIt').curloc = Data.path;   
                DataArr2.(['Data_File',num2str(n),'_Data']) = DataArr.(['Data_File',num2str(n),'_Data']);
            end
        end
        SCRPTGBL.([callingfuncs{1},'_Data']) = DataArr2;    
    end
end
    
end
end