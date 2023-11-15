%====================================================
%
%====================================================

function [default] = StitchItImage_Local_v2a_Default2(SCRPTPATHS)

path = SCRPTPATHS.voyagerloc;
Datafunc = 'DataSiemensV1a';
Reconfunc = 'ReconNufftExtOffResV1a';

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
default{m,1}.labelstr = 'Datafunc';
default{m,1}.entrystr = Datafunc;
default{m,1}.searchpath = path;
default{m,1}.path = [path,Datafunc];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'Reconfunc';
default{m,1}.entrystr = Reconfunc;
default{m,1}.searchpath = path;
default{m,1}.path = [path,Reconfunc];

m = m+1;
default{m,1}.entrytype = 'RunScrptFunc';
default{m,1}.scrpttype = 'Image';
default{m,1}.labelstr = 'Create Image';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Run';

