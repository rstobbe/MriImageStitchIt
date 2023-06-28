%====================================================
% (v1a)
%      
%====================================================

function [SCRPTipt,SCRPTGBL,err] = StitchItImage_Local_v1a(SCRPTipt,SCRPTGBL)

Status('busy','Create Image');
Status2('done','',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Clear Naming
%---------------------------------------------
inds = strcmp('Image_Name',{SCRPTipt.labelstr});
indnum = find(inds==1);
if length(indnum) > 1
    indnum = indnum(SCRPTGBL.RWSUI.scrptnum);
end
SCRPTipt(indnum).entrystr = '';
setfunc = 1;
DispScriptParam(SCRPTipt,setfunc,SCRPTGBL.RWSUI.tab,SCRPTGBL.RWSUI.panelnum);
SCRPTipt0 = SCRPTipt;

%---------------------------------------------
% Load Input
%---------------------------------------------
IMG.method = SCRPTGBL.CurrentTree.Func;
IMG.stitchitdatafunc = SCRPTGBL.CurrentTree.('StitchItDatafunc').Func;
IMG.stitchitreconfunc = SCRPTGBL.CurrentTree.('StitchItReconfunc').Func;

%---------------------------------------------
% Get Working Structures from Sub Functions
%---------------------------------------------
STCHDATAipt = SCRPTGBL.CurrentTree.('StitchItDatafunc');
if isfield(SCRPTGBL,('StitchItDatafunc_Data'))
    STCHDATAipt.StitchItDatafunc_Data = SCRPTGBL.StitchItDatafunc_Data;
end
STCHRECONipt = SCRPTGBL.CurrentTree.('StitchItReconfunc');
if isfield(SCRPTGBL,('StitchItReconfunc_Data'))
    STCHRECONipt.StitchItReconfunc_Data = SCRPTGBL.StitchItReconfunc_Data;
end

%------------------------------------------
% Import Function Info
%------------------------------------------
func = str2func(IMG.stitchitdatafunc); 
[SCRPTipt,SCRPTGBL,STCHDATA,err] = func(SCRPTipt,SCRPTGBL,STCHDATAipt);
if err.flag
    return
end
func = str2func(IMG.stitchitreconfunc); 
STCHRECON = func();
STCHRECON.InitViaCompass(STCHRECONipt);

%---------------------------------------------
% Stitch Image
%---------------------------------------------
func = str2func([IMG.method,'_Func']);
INPUT.STCHDATA = STCHDATA;
INPUT.STCHRECON = STCHRECON;
[IMG,err] = func(INPUT,IMG);
if err.flag
    return
end

%--------------------------------------------
% Output to TextBox
%--------------------------------------------
IMG.ExpDisp = PanelStruct2Text(IMG.PanelOutput);
global FIGOBJS
if strcmp(SCRPTGBL.RWSUI.tab(1:2),'IM')
    FIGOBJS.(SCRPTGBL.RWSUI.tab).InfoL.String = IMG.ExpDisp;
else
    FIGOBJS.(SCRPTGBL.RWSUI.tab).Info.String = IMG.ExpDisp;
end

%--------------------------------------------
% Determine if AutoSave
%--------------------------------------------
auto = 0;
RWSUI = SCRPTGBL.RWSUI;
if isfield(RWSUI,'ExtRunInfo')
    auto = 1;
    if strcmp(RWSUI.ExtRunInfo.save,'no')
        SCRPTGBL.RWSUI.SaveScript = 'no';
        SCRPTGBL.RWSUI.SaveGlobal = 'no';
    elseif strcmp(RWSUI.ExtRunInfo.save,'all')
        SCRPTGBL.RWSUI.SaveScript = 'yes';
        SCRPTGBL.RWSUI.SaveGlobal = 'yes';
    elseif strcmp(RWSUI.ExtRunInfo.save,'global')
        SCRPTGBL.RWSUI.SaveScript = 'no';
        SCRPTGBL.RWSUI.SaveGlobal = 'yes';
    end
    name = ['IMG_',RWSUI.ExtRunInfo.name];
else
    SCRPTGBL.RWSUI.SaveScriptOption = 'yes';
    SCRPTGBL.RWSUI.SaveGlobal = 'yes';
end

%--------------------------------------------
% Name
%--------------------------------------------
if auto == 0
    name = inputdlg('Name Image:','Name Image',[1 60],{IMG.name});
    name = cell2mat(name);
    if isempty(name)
        SCRPTipt = SCRPTipt0;
        setfunc = 1;
        DispScriptParam(SCRPTipt,setfunc,SCRPTGBL.RWSUI.tab,SCRPTGBL.RWSUI.panelnum);
        SCRPTGBL.RWSUI.SaveVariables = {IMG};
        SCRPTGBL.RWSUI.KeepEdit = 'yes';
        return
    end
end
IMG.name = name;
IMG.type = 'Image';   

%---------------------------------------------
% Return
%---------------------------------------------
SCRPTipt(indnum).entrystr = IMG.name;
SCRPTGBL.RWSUI.SaveVariables = IMG;
SCRPTGBL.RWSUI.SaveVariableNames = 'IMG';
SCRPTGBL.RWSUI.SaveGlobalNames = IMG.name;
SCRPTGBL.RWSUI.SaveScriptPath = IMG.path;
SCRPTGBL.RWSUI.SaveScriptName = IMG.name;

Status('done','');
Status2('done','',2);
Status2('done','',3);
