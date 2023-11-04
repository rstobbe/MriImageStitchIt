%==================================================================
% (v2c)
%   - Iterate
%==================================================================

classdef StitchItRecon_ReturnOffResMap_v2d < handle

properties (SetAccess = private)                   
    Method = 'StitchItRecon_ReturnOffResMap_v2d'
    BaseMatrix
    AcqInfoOffRes
    Iterate
    RelMaskVal
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function RECON = StitchItRecon_ReturnOffResMap_v2d()              
end

%==================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(RECON,RECONipt)    

    RECON.BaseMatrix = str2double(RECONipt.('BaseMatrix'));
    RECON.Iterate = RECONipt.('Iterate');
    RECON.RelMaskVal = str2double(RECONipt.('RelMaskVal'));
    
    CallingLabel = RECONipt.Struct.labelstr;
    if not(isfield(RECONipt,[CallingLabel,'_Data']))
        if isfield(RECONipt.('Recon_File').Struct,'selectedfile')
            file = RECONipt.('Recon_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Recon_File';
                ErrDisp(err);
                return
            else
                load(file);
                RECONipt.([CallingLabel,'_Data']).('Recon_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Recon_File';
            ErrDisp(err);
            return
        end
    end
    RECON.AcqInfoOffRes = RECONipt.([CallingLabel,'_Data']).('Recon_File_Data').WRT.STCHOR;    
end

%==================================================================
% SetBaseMatrix
%==================================================================  
function SetBaseMatrix(RECON,val)    
    RECON.BaseMatrix = val;
end

%==================================================================
% CreateImage
%==================================================================  
function [IMG,err] = CreateImage(RECON,DataObj)     
    %% Test  
    err.flag = 0;
    IMG = [];
    if ~strcmp(RECON.AcqInfoOffRes{1}.name,DataObj.DataInfo.TrajName)
        answer = questdlg('Data and Recon have different names - continue?');
        switch answer
            case 'No'
                err.flag = 1;
                err.msg = 'Data and Recon do not match';
                return
            case 'Cancel'
                err.flag = 1;
                err.msg = 'Data and Recon do not match';
                return
        end
    end

    %% Reset GPUs
    DisplayStatusCompass('Reset GPUs',2);
    for n = 1:gpuDeviceCount
        gpuDevice(n);
    end

    %% Create Off Resonance Map
    DisplayStatusCompass('Off Resonance Map',2);
    OffResImageNumber = 1;
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);        
    DisplayStatusCompass('Image1: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Image1: Generate',3);
    Image1 = StitchIt.CreateImage(Data);
    
    OffResImageNumber = 2;
    DisplayStatusCompass('Load Data',3);
    Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);        
    DisplayStatusCompass('Image2: Initialize',3);
    StitchIt = StitchItReturnChannels(); 
    StitchIt.SetBaseMatrix(RECON.BaseMatrix);
    StitchIt.SetFov2ReturnBaseMatrix;
    RxChannels = DataObj.RxChannels;
    StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
    Data = DataObj.ScaleData(StitchIt,Data);
    DisplayStatusCompass('Image2: Generate',3);
    Image2 = StitchIt.CreateImage(Data);
    
    DisplayStatusCompass('Combine Images',3);
    Image = cat(5,Image1,Image2);
    RefCoil = 5;
    Vox = RECON.AcqInfoOffRes{OffResImageNumber}.Fov./RECON.BaseMatrix;
    Vox = [Vox Vox Vox];
    KernRad = 20;
    %--
    %[Image,Sens] = AdaptiveCmbRws(Image,Vox,RefCoil,KernRad);
    [Image,Sens] = AdaptiveCmbRws2(Image,Vox,RefCoil,KernRad);
    %--
    ImportImageCompass(Image,'Image');
    ImportImageCompass(Sens,'Sens');

    DisplayStatusCompass('Create Map',3);
    TimeDiff = (RECON.AcqInfoOffRes{2}.SampStartTime - RECON.AcqInfoOffRes{1}.SampStartTime)/1000;
    OffResMap0 = (angle(Image(:,:,:,2))-angle(Image(:,:,:,1)))/(2*pi*TimeDiff);
    OffResMap = single(OffResMap0);
    
    MaxFreq = 0.5/TimeDiff;    
    OffResMap(OffResMap0 < -MaxFreq) = 1/TimeDiff + OffResMap0(OffResMap0 < -MaxFreq);
    OffResMap(OffResMap0 > MaxFreq) = OffResMap0(OffResMap0 > MaxFreq) - 1/TimeDiff;
    
    MaskImage = abs(Image(:,:,:,1));
    OffResMap(MaskImage < RECON.RelMaskVal*max(MaskImage(:))) = 0;
    MaskImage = abs(Image(:,:,:,2));
    OffResMap(MaskImage < RECON.RelMaskVal*max(MaskImage(:))) = 0;
   
    totgblnum = ImportOffResMapCompass(OffResMap,'OffResMap',[],[],max(abs(OffResMap(:))));
    Gbl2ImageOrtho('IM3',totgblnum);
    
    
    if strcmp(RECON.Iterate,'Yes')
        %% Sampling Timing
        OffResTimeArr = RECON.AcqInfoOffRes{1}.OffResTimeArr;    

        %% Create Off Resonance Map
        ItNum = 2;
        for n = 2:ItNum
            DisplayStatusCompass('Off Resonance Map',2);
            OffResImageNumber = 1;
            DisplayStatusCompass('Load Data',3);
            Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);           
            DisplayStatusCompass('Image1: Initialize',3);
            StitchIt = StitchItReturnChannelsOffRes(); 
            StitchIt.SetBaseMatrix(RECON.BaseMatrix);
            StitchIt.SetFov2ReturnBaseMatrix;
            RxChannels = DataObj.RxChannels;
            StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
            Data = DataObj.ScaleData(StitchIt,Data);
            DisplayStatusCompass('Image1: Generate',3);
            Image1 = StitchIt.CreateImage(Data,OffResMap,OffResTimeArr);

            OffResImageNumber = 2;
            DisplayStatusCompass('Load Data',3);
            Data = DataObj.ReturnDataSetWithShift(RECON.AcqInfoOffRes{OffResImageNumber},OffResImageNumber);             
            DisplayStatusCompass('Image2: Initialize',3);
            StitchIt = StitchItReturnChannelsOffRes();  
            StitchIt.SetBaseMatrix(RECON.BaseMatrix);
            StitchIt.SetFov2ReturnBaseMatrix;
            RxChannels = DataObj.RxChannels;
            StitchIt.Initialize(RECON.AcqInfoOffRes{OffResImageNumber},RxChannels); 
            Data = DataObj.ScaleData(StitchIt,Data);
            DisplayStatusCompass('Image2: Generate',3);
            Image2 = StitchIt.CreateImage(Data,OffResMap,OffResTimeArr);

            Image = cat(5,Image1,Image2);
            RefCoil = 5;
            Vox = RECON.AcqInfoOffRes{OffResImageNumber}.Fov./RECON.BaseMatrix;
            Vox = [Vox Vox Vox];
            KernRad = 20;
            %--
            %[Image,Sens] = AdaptiveCmbRws(Image,Vox,RefCoil,KernRad);
            [Image,Sens] = AdaptiveCmbRws2(Image,Vox,RefCoil,KernRad);
            %--
            ImportImageCompass(Image,'Image');
            ImportImageCompass(Sens,'Sens');

            TimeDiff = (RECON.AcqInfoOffRes{2}.SampStartTime - RECON.AcqInfoOffRes{1}.SampStartTime)/1000;
            OffResMap0 = (angle(Image(:,:,:,2))-angle(Image(:,:,:,1)))/(2*pi*TimeDiff);
            OffResMap = single(OffResMap0);
            
            DisplayStatusCompass('Create Map',3);
            MaxFreq = 0.5/TimeDiff;    
            OffResMap(OffResMap0 < -MaxFreq) = 1/TimeDiff + OffResMap0(OffResMap0 < -MaxFreq);
            OffResMap(OffResMap0 > MaxFreq) = OffResMap0(OffResMap0 > MaxFreq) - 1/TimeDiff;
            
            MaskImage = abs(Image(:,:,:,1));
            OffResMap(MaskImage < RECON.RelMaskVal*max(MaskImage(:))) = 0;
            MaskImage = abs(Image(:,:,:,2));
            OffResMap(MaskImage < RECON.RelMaskVal*max(MaskImage(:))) = 0;

            totgblnum = ImportOffResMapCompass(OffResMap,'OffResMap',[],[],max(abs(OffResMap(:))));
            Gbl2ImageOrtho('IM3',totgblnum);
        end
    end

    
    %% Return
    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'BaseMatrix',RECON.BaseMatrix,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    
    NameSuffix = 'OffResMap';
    IMG = AddCompassMapInfo(OffResMap,DataObj,RECON.AcqInfoOffRes{1},StitchIt,PanelOutput,NameSuffix);
    
end

end
end