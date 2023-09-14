%====================================================
%
%====================================================

function [default] = StitchItRecon_ReturnChannelsOffRes_v2b_Default2(SCRPTPATHS)

global COMPASSINFO

m = 1;
default{m,1}.entrytype = 'RunExtFunc';
default{m,1}.labelstr = 'Recon_File';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Load';
default{m,1}.runfunc1 = 'LoadReconCur';
default{m,1}.(default{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
default{m,1}.runfunc2 = 'LoadReconDisp';
default{m,1}.(default{m,1}.runfunc2).defloc = COMPASSINFO.USERGBL.trajreconloc;

m = m+1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'BaseMatrix';
default{m,1}.entrystr = 140;
mat = (10:10:500).';
default{m,1}.options = mat2cell(mat,length(mat));

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'ReconNumber';
default{m,1}.entrystr = '1';




