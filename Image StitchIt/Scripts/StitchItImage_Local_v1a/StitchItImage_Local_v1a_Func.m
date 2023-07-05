%====================================================
%  
%====================================================

function [IMG,err] = StitchItImage_Local_v1a_Func(INPUT,IMG)

Status('busy','Create Image');
Status2('done','',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Get Input
%---------------------------------------------
STCHDATA = INPUT.STCHDATA;
STCHRECON = INPUT.STCHRECON;
clear INPUT;

%----------------------------------------------
% Stitch Run
%----------------------------------------------
Status2('busy','StitchIt Run',2);
[IMG,err] = STCHRECON.CreateImage(STCHDATA.DATA.DataObj);

Status2('done','',1);
Status2('done','',2);
Status2('done','',3);


