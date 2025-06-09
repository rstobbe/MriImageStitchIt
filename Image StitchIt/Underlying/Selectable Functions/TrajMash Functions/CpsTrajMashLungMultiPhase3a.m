%==================================================================
% (3a)
%   - 
%==================================================================

classdef CpsTrajMashLungMultiPhase3a < handle

properties (SetAccess = private)                   
    TrajMashObj
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsTrajMashLungMultiPhase3a()              
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Ipt)    
    obj.TrajMashObj = TrajMashLungMultiPhase3a();   
    obj.TrajMashObj.SetStartSkip(str2double(Ipt.('StartSkip')));
    obj.TrajMashObj.SetDispFigs(str2double(Ipt.('DispFigs')));
    obj.TrajMashObj.SetPeakFindSensitivity(str2double(Ipt.('PeakFindSensitivity')));
    obj.TrajMashObj.SetPhases(str2double(Ipt.('NumPhases')));
    obj.TrajMashObj.SetFlip(str2double(Ipt.('FlipNavigator')));
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
    Panel(6,:) = {'PeakFindSensitivity',obj.TrajMashObj.PeakFindSensitivity,'Output'};   
    Panel(7,:) = {'MeanAvesUsedPerTraj',obj.TrajMashObj.MeanTrajsUsed,'Output'};
    Panel(8,:) = {'PeriValsFraction',obj.TrajMashObj.PeriValsFraction,'Output'};
    Panel(9,:) = {'HoleFraction',obj.TrajMashObj.HoleFraction,'Output'};
    Panel(10,:) = {'CoilUsed',obj.TrajMashObj.UseCoil,'Output'};
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
    Interface{m,1}.options = {'1','2','3','4','5','6','7','8'};
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'NumPhases';
    Interface{m,1}.entrystr = '20';
    m = m+1;
    Interface{m,1}.entrytype = 'Choose';
    Interface{m,1}.labelstr = 'FlipNavigator';
    Interface{m,1}.entrystr = '0';
    Interface{m,1}.options = {'0','1'};
end 

end
end