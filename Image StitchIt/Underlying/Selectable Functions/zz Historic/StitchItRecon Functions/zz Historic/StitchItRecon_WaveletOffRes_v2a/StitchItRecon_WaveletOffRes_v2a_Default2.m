%====================================================
%
%====================================================

function [default] = StitchItRecon_WaveletPreWgt_v2a_Default2(SCRPTPATHS)

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
default{m,1}.entrystr = 100;
mat = (10:10:500).';
default{m,1}.options = mat2cell(mat,length(mat));

m = m+1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'Fov2Return';
default{m,1}.entrystr = 'BaseMatrix';
default{m,1}.options = {'BaseMatrix','GridMatrix'};

m = m+1;
default{m,1}.entrytype = 'Choose';
default{m,1}.labelstr = 'PreScaleRxChans';
default{m,1}.entrystr = 'No';
default{m,1}.options = {'No','Linear','Root','ReduceHotLinear','ReduceHotRoot'};

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'ReconNumber';
default{m,1}.entrystr = '1';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'LevelsPerDim';
default{m,1}.entrystr = '111';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'Lambda';
default{m,1}.entrystr = '0.1';

m = m+1;
default{m,1}.entrytype = 'Input';
default{m,1}.labelstr = 'NumIterations';
default{m,1}.entrystr = '50';



