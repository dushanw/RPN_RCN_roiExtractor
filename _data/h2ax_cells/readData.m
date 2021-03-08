% 20210307 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)

function [I L] = readData(pram)

  expNames = {'imageLabeling_1Gy_15Min',...
              'imageLabeling_1Gy_30Min',...
              'imageLabeling_1Gy_45Min',...
              'imageLabeling_1Gy_1Hr',...
              'imageLabeling_1Gy_2Hr',...
              'imageLabeling_1Gy_4Hr',...
              'imageLabeling_1Gy_8Hr',...
              'imageLabeling_NT_1Hr'}; 

  I.tr    = [];
  L.tr    = [];
  I.test  = [];
  L.test  = [];
  t       = 1;
  for i = 1:length(expNames)
    load(['./' expNames{i} '/I_cell.mat'])
    load(['./' expNames{i} '/L_h2ax.mat'])
    
    N_cells   = length(I_cell);
    rand_inds = randperm(N_cells);
        
    test_inds = 1:round(N_cells*pram.TestDataRatio);
    tr_inds   = test_inds(end)+1:N_cells;
    
    I.tr      = [I.tr   {I_cell{rand_inds(tr_inds  )}}];    
    I.test    = [I.test {I_cell{rand_inds(test_inds)}}];
    
    L.tr      = [L.tr   {L_h2ax{rand_inds(tr_inds  )}}];
    L.test    = [L.test {L_h2ax{rand_inds(test_inds)}}];   
    for j=1:length(test_inds)
      I.test_nameStem{t}  = [expNames{i} '_' sprintf('%d',j)];
      t                   = t + 1;
    end
  end
  
  I.tr    = subf_normalize_tissue_to_1(I.tr);
  I.test  = subf_normalize_tissue_to_1(I.test);
      
end



function I = subf_normalize_tissue_to_1(I)

  for i = 1:length(I)
    I{i}            = single(I{i});
    I_nuc           = I{i}(:,:,1);
    intensity_range = linspace(0,max(I_nuc(:)),40);
    hist_I          = hist(I_nuc(:),intensity_range);

    [pks locs]      = findpeaks(hist_I);
    intensity_cell  = intensity_range(locs(end));% last peak is the cell background

    I{i}             = I{i}(:,:,2)/intensity_cell;% select the foci channel
  end
  
end