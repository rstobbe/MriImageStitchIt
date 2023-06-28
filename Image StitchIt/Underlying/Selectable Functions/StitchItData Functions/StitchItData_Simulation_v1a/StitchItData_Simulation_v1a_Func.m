%=====================================================
%
%=====================================================

function [DATA,err] = StitchData_Simulation_v1a_Func(DATA,INPUT)

Status2('busy','Stitch Data',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Build Object
%---------------------------------------------
DataObj = SimulationDataObject(DATA.DATA.loc);  
DATA.DataObj = DataObj;

Status2('done','',2);
Status2('done','',3);
