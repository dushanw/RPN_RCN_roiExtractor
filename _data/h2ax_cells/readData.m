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
  end

end