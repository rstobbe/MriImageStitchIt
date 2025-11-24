%==================================================================
% (V2c)
%   - 
%==================================================================

classdef CpsTrajMashUseAllEqual3e < handle

properties (SetAccess = private)                   
    TrajMashObj
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CpsTrajMashUseAllEqual3e()              
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,Ipt)    
    obj.TrajMashObj = TrajMashUseAllEqual3e();   
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