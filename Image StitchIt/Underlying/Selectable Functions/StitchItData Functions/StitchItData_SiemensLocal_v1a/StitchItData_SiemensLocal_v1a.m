%=========================================================
% (v1a)
%      
%=========================================================

function [SCRPTipt,SCRPTGBL,DATA,err] = StitchData_SiemensLocal_v1a(SCRPTipt,SCRPTGBL,DATAipt)

Status2('busy','Load DATA',2);
Status2('done','',2);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
DATA.method = DATAipt.Func;
PanelLabel = 'Data_File';
CallingLabel = DATAipt.Struct.labelstr;

%---------------------------------------------
% Tests
%---------------------------------------------
auto = 0;
RWSUI = SCRPTGBL.RWSUI;
if isfield(RWSUI,'ExtRunInfo')
    auto = 1;
    ExtRunInfo = RWSUI.ExtRunInfo;
end

%---------------------------------------------
% Tests
%---------------------------------------------
if auto == 1
    saveData = ExtRunInfo.saveData;
    [SCRPTipt,SCRPTGBL,err] = SiemensStitch2Panel(SCRPTipt,SCRPTGBL,CallingLabel,PanelLabel,saveData);
    DATA.DATA = SCRPTGBL.([CallingLabel,'_Data']).([PanelLabel,'_Data']);
else
    CallingLabel = DATAipt.Struct.labelstr;
    if not(isfield(DATAipt,[CallingLabel,'_Data']))
        if isfield(DATAipt.('Data_File').Struct,'selectedfile')
            file = DATAipt.('Data_File').Struct.selectedfile;
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
                SCRPTGBL.RWSUI.funclabel = 'Data_File';
                SCRPTGBL.RWSUI.callingfuncs{1} = 'StitchDatafunc';
                [SCRPTipt,SCRPTGBL,err] = SelectSiemensDataExpStitch(SCRPTipt,SCRPTGBL,saveData);
                if err.flag
                    ErrDisp(err);
                    return
                end
                DATA.DATA = SCRPTGBL.([CallingLabel,'_Data']).([PanelLabel,'_Data']);
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Data_File';
            ErrDisp(err);
            return
        end
    else    
        DATA.DATA = DATAipt.([CallingLabel,'_Data']).([PanelLabel,'_Data']);
    end
end

Status2('done','',2);
Status2('done','',3);