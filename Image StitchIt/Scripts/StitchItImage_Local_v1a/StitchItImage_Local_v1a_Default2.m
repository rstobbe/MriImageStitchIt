%====================================================
%
%====================================================

function [default] = StitchItImage_Local_v1a_Default2(SCRPTPATHS)

stitchpath = SCRPTPATHS.voyagerloc;
stitchdatafunc = 'StitchItData_SiemensLocal_v1a';
stitchitreconfunc = 'StitchItRecon_ReturnChannels_v2a';

m = 1;
default{m,1}.entrytype = 'OutputName';
default{m,1}.labelstr = 'Image_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScriptName';
default{m,1}.labelstr = 'Script_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'StitchItDatafunc';
default{m,1}.entrystr = stitchdatafunc;
default{m,1}.searchpath = stitchpath;
default{m,1}.path = [stitchpath,stitchdatafunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'StitchItReconfunc';
default{m,1}.entrystr = stitchitreconfunc;
default{m,1}.searchpath = stitchpath;
default{m,1}.path = [stitchpath,stitchitreconfunc];

m = m+1;
default{m,1}.entrytype = 'RunScrptFunc';
default{m,1}.scrpttype = 'Image';
default{m,1}.labelstr = 'Create Image';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Run';

