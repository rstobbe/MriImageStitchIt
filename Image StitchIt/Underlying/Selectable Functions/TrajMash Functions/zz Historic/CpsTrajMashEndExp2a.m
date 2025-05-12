%==================================================================
% (V2a)
%   - 
%==================================================================

classdef CpsTrajMashEndExp2a < handle

properties (SetAccess = private)                   
    TrajMashObj
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsTrajMashEndExp2a()              
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Ipt)    
    obj.TrajMashObj = TrajMashEndExp2a();   
    obj.TrajMashObj.SetStartSkip(str2double(Ipt.('StartSkip')));
    obj.TrajMashObj.SetDispFigs(str2double(Ipt.('DispFigs')));
    obj.TrajMashObj.SetPeakFindSensitivity(str2double(Ipt.('PeakFindSensitivity')));
    obj.TrajMashObj.SetAtExpirationFrac(str2double(Ipt.('AtExpirationFrac')));
    obj.TrajMashObj.SetPolarity(str2double(Ipt.('Polarity')));
end

%=================================================================
% ReturnInfoCompass
%==================================================================  
function Panel = ReturnInfoCompass(obj) 
    Panel(1,:) = {'TrajMashObj',obj.TrajMashObj.Method,'Output'};
    Panel(2,:) = {'StartSkip',obj.TrajMashObj.StartSkip,'Output'};
    Panel(3,:) = {'FilterTime',obj.TrajMashObj.FilterTime,'Output'};
    Panel(4,:) = {'AtExpirationFrac',obj.TrajMashObj.AtExpirationFrac,'Output'};
    Panel(5,:) = {'AtExpirationPerFrac',obj.TrajMashObj.AtExpirationPeriFrac,'Output'};
    Panel(6,:) = {'Polarity',obj.TrajMashObj.Polarity,'Output'};  
    Panel(7,:) = {'PeakFindSensitivity',obj.TrajMashObj.PeakFindSensitivity,'Output'};   
    Panel(8,:) = {'MeanAvesUsedPerTraj',obj.TrajMashObj.MeanTrajsUsed,'Output'};
    Panel(9,:) = {'PeriValsFraction',obj.TrajMashObj.PeriValsFraction,'Output'};
    Panel(10,:) = {'HoleFraction',obj.TrajMashObj.HoleFraction,'Output'};
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    m = 1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'StartSkip';
    Interface{m,1}.entrystr = '2000';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'DispFigs';
    Interface{m,1}.entrystr = '0';
    Interface{m,1}.options = {'0','1','2'};
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'PeakFindSensitivity';
    Interface{m,1}.entrystr = '3';
    Interface{m,1}.options = {'1','2','3','4','5'};
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'AtExpirationFrac';
    Interface{m,1}.entrystr = '0.25';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'Polarity';
    Interface{m,1}.entrystr = '1';
    Interface{m,1}.options = {'-1','1'};
end 

end
end