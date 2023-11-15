%==================================================================
% (V1a)
%   
%==================================================================

classdef DataSiemensV1a < handle

properties (SetAccess = private)                   
    Recon
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = DataSiemensV1a()              
end

%=================================================================
% InitViaCompass
%==================================================================  
function [SCRPTipt,SCRPTGBL,DATA,err] = InitViaCompass(obj,SCRPTipt,SCRPTGBL,DATAipt) 
    
    err.flag = 0;
    DATA.method = DATAipt.Func;
    PanelLabel = 'Data_File';
    CallingLabel = DATAipt.Struct.labelstr;
    if not(isfield(DATAipt,[CallingLabel,'_Data']))
        if isfield(DATAipt.(PanelLabel).Struct,'selectedfile')
            file = DATAipt.(PanelLabel).Struct.selectedfile;
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
                SCRPTGBL.RWSUI.funclabel = PanelLabel;
                SCRPTGBL.RWSUI.callingfuncs{1} = 'StitchDatafunc';
                [SCRPTipt,SCRPTGBL,err] = SelectSiemensDataExpStitch(SCRPTipt,SCRPTGBL,saveData);
                if err.flag
                    ErrDisp(err);
                    return
                end
                DATA.DATA{1} = SCRPTGBL.([CallingLabel,'_Data']).([PanelLabel,'_Data']);
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Data_File';
            ErrDisp(err);
            return
        end
    else    
        DATA.DATA{1} = DATAipt.([CallingLabel,'_Data']).([PanelLabel,'_Data']);
    end

end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    global COMPASSINFO
    m = 1;
    Interface{m,1}.entrytype = 'RunExtFunc';
    Interface{m,1}.labelstr = 'Data_File';
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
end