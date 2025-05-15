%==================================================================
% (V1a)
%   
%==================================================================

classdef ReconStitchItWaveletExtOffResV1a < handle

properties (SetAccess = private)                   
    Recon
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = ReconStitchItWaveletExtOffResV1a()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj,DATA)     
    [Image,err] = obj.Recon.CreateImage(DATA);
       
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    Panel(3,:) = {'NumIterations',obj.Recon.NumIterations,'Output'};
    Panel(4,:) = {'Lambda',obj.Recon.Lambda,'Output'};
    Panel(5,:) = {'LevelsPerDim',obj.Recon.LevelsPerDim,'Output'};
    Panel(6,:) = {'MaxEig',obj.Recon.MaxEig,'Output'};
    Panel(7,:) = {'OffResCorrection','No','Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'StitchItOffResCor';
    IMG = AddCompassInfo(Image,DATA{1}.DataObj,obj.Recon.AcqInfo{obj.Recon.ReconNumber},obj,PanelOutput,NameSuffix);         
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Reconipt)    
    obj.Recon = ReconStitchItWaveletV1a();   
    obj.Recon.SetBaseMatrix(str2double(Reconipt.('BaseMatrix')));
    obj.Recon.SetReconNumber(str2double(Reconipt.('ReconNumber')));
    if strcmp(Reconipt.('OffResCorrection'),'Yes')
        obj.Recon.SetOffResCorrection(1);
    else
        obj.Recon.SetOffResCorrection(0);
    end
    LevelsPerDim0 = Reconipt.('LevelsPerDim');
    for n = 1:3
        LevelsPerDim(n) = str2double(LevelsPerDim0(n));
    end
    obj.Recon.SetLevelsPerDim(LevelsPerDim);
    obj.Recon.SetLambda(str2double(Reconipt.('Lambda')));
    obj.Recon.SetNumIterations(str2double(Reconipt.('NumIterations'))); 
    if not(isempty(Reconipt.('MaxEig')))
        obj.Recon.SetMaxEig(str2double(Reconipt.('MaxEig')));
    end
    if strcmp(Reconipt.('DisplayRxProfs'),'Yes')
        obj.Recon.SetDisplayRxProfs(1);
    end 
    if strcmp(Reconipt.('DisplayOffResMap'),'Yes')
        obj.Recon.SetDisplayOffResMap(1);
    end 
    if strcmp(Reconipt.('DisplayInitialImages'),'Yes')
        obj.Recon.SetDisplayInitialImages(1);
    end 
    if strcmp(Reconipt.('DisplayIterations'),'Yes')
        obj.Recon.SetDisplayIterations(1);
    end 
    obj.Recon.SetDisplayIterationStep(str2double(Reconipt.('DisplayIterationStep')));
    if strcmp(Reconipt.('SaveEachDispIteration'),'Yes')
        obj.Recon.SetSaveIterationStep(1);
    end 
    if strcmp(Reconipt.('DoMemRegister'),'Yes')
        obj.Recon.SetDoMemRegister(1);
    else
        obj.Recon.SetDoMemRegister(0);
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
    obj.Recon.SetOffResMap(single(Reconipt.([CallingLabel,'_Data']).('OffResMap_File_Data').IMG.Im));
    obj.Recon.SetShift(single(Reconipt.([CallingLabel,'_Data']).('OffResMap_File_Data').IMG.FovShift));
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
    Interface{m,1}.entrytype = 'RunExtFunc';
    Interface{m,1}.labelstr = 'OffResMap_File';
    Interface{m,1}.entrystr = '';
    Interface{m,1}.buttonname = 'Load';
    Interface{m,1}.runfunc1 = 'LoadImageCur';
    Interface{m,1}.(Interface{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
    Interface{m,1}.runfunc2 = 'LoadImageDisp';
    Interface{m,1}.(Interface{m,1}.runfunc2).defloc = COMPASSINFO.USERGBL.trajreconloc;
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'BaseMatrix';
    Interface{m,1}.entrystr = 140;
    mat = (10:10:500).';
    Interface{m,1}.options = mat2cell(mat,length(mat));
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'ReconNumber';
    Interface{m,1}.entrystr = '1';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'OffResCorrection';
    Interface{m,1}.entrystr = 'Yes';
    Interface{m,1}.options = {'No','Yes'};
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'LevelsPerDim';
    Interface{m,1}.entrystr = '222';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'Lambda';
    Interface{m,1}.entrystr = '20';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'NumIterations';
    Interface{m,1}.entrystr = '5';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'MaxEig';
    Interface{m,1}.entrystr = '';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DisplayRxProfs';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DisplayOffResMap';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DisplayInitialImages';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DisplayIterations';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'DisplayIterationStep';
    Interface{m,1}.entrystr = '';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'SaveEachDispIteration';
    Interface{m,1}.entrystr = 'No';
    Interface{m,1}.options = {'Yes','No'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DoMemRegister';
    Interface{m,1}.entrystr = 'Yes';
    Interface{m,1}.options = {'No','Yes'};
end 

end
end