%==================================================================
% (V2c)
%   - 
%==================================================================

classdef CpsTrajMashUseAllEqual2b < handle

properties (SetAccess = private)                   
    TrajMashObj
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsTrajMashUseAllEqual2b()              
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Ipt)    
    obj.TrajMashObj = TrajMashUseAllEqual2b();   
end

%=================================================================
% ReturnInfoCompass
%==================================================================  
function Panel = ReturnInfoCompass(obj) 
    Panel(1,:) = {'TrajMashObj',obj.TrajMashObj.Method,'Output'};
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    Interface = cell(1);
end

end
end