%==================================================================
% (V1a)
%   
%==================================================================

classdef CpsReconSb0mapV2a < handle

properties (SetAccess = private)                   
    Recon
    RelAbsThresh
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsReconSb0mapV2a()              
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(obj,DATA)     
    [Image,err] = obj.Recon.CreateImage(DATA);
    
    %-------------------------------------------
    % Sodium Scale
    %-------------------------------------------    
    Image = Image*10000;

    %-------------------------------------------
    % Off-Resonance Map
    %-------------------------------------------
    TeSep = (DATA{1}.ExpPars.Sequence.te(2) - DATA{1}.ExpPars.Sequence.te(1))/1000;
    Im1 = Image(:,:,:,:,:,1);
    Im2 = Image(:,:,:,:,:,2);
    AbsIm = abs(Im1);
    Mask = ones(size(AbsIm));
    Mask(AbsIm < obj.RelAbsThresh*max(AbsIm(:))) = NaN;
    phIm1 = angle(Im1);
    phIm2 = angle(Im2);
    dphIm = phIm2 - phIm1;
    dphIm(dphIm > pi) = dphIm(dphIm > pi) - 2*pi;
    dphIm(dphIm < -pi) = dphIm(dphIm < -pi) + 2*pi;
    dphIm = dphIm.*Mask; 
    FreqMap = (dphIm/(2*pi))/TeSep;

    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'ReconMatrix',obj.Recon.BaseMatrix,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'B0';
    IMG = AddCompassInfo(FreqMap,DATA{1}.DataObj,obj.Recon.AcqInfo{1},obj,PanelOutput,NameSuffix);         
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Reconipt)    
    obj.Recon = ReconSfpV2a();   
    obj.Recon.SetBaseMatrix(str2double(Reconipt.('BaseMatrix')));
    obj.RelAbsThresh = str2double(Reconipt.('RelAbsThresh'));
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
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'RelAbsThresh';
    Interface{m,1}.entrystr = '0.2';
end 

end
end