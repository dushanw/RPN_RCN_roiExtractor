% 20210307 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)

function [I L] = readData(pram)

%%  experimeent details
%               % --- NDMA ----|----rest-----
%   inds_tr     = [1 2 3 4 5 6   7 8 9 10 11];  
%   inds_test   = [1 2           3 4];

  load('I_nuc_tissue.mat')
  
  I.tr   = subf_normalize_tissue_to_1(I.tr);
  L.tr   = subf_preProcLabels(L.tr);
  
  I.test = subf_normalize_tissue_to_1(I.test);
  I.test = subf_preProcLabels(L.test);
end

% preproceessing functions
function I = subf_normalize_tissue_to_1(I)
  for i = 1:length(I)
    I{i}              = single(I{i});
    
    intensity_range   = linspace(0,max(I{i}(:)),40);
    hist_I_tissueBg   = hist(I{i}(:),intensity_range);
%   plot(intensity_range,hist_I_tissueBg);
    [pks locs]        = findpeaks(hist_I_tissueBg);
    [temp indMx]      = max(pks);
    intensity_tissueBg= intensity_range(locs(indMx));% last peak is the tissue background
    
    I{i}              = I{i}/intensity_tissueBg;
  end  
end

function L = subf_preProcLabels(L)
  for i = 1:length(L)    
    L{i} = bwmorph(L{i},'clean');    
    L{i} = bwmorph(L{i},'thin');
    L{i} = bwmorph(L{i},'open');        
  end  
end







