
function [XTr, YTr, XVal, YVal] = readData(pram)
  
  Bacteria_Names = {'Acinetobacter_Old',...
                    'B_subtilis_Old',...
                    'E_coli_K12_Old',...
                    'E_coli_CCUG17620_New',...
                    'E_coli_NCTC13441_New',...
                    'K_pneumoniae_A2-23_New',...
                    'S_aureus_CCUG35600_New'};

  dataFileNames  = {'./cropped/Bac01.mat',...
                    './cropped/Bac02.mat',...
                    './cropped/Bac03.mat',...
                    './cropped/Bac01_n.mat',...
                    './cropped/Bac02_n.mat',...
                    './cropped/Bac04_n.mat',...
                    './cropped/Bac05_n.mat'};
  midCropAtRead  = 32;                                      % original image are of 100x100 but the object is in a smaller region in the middle.
                  
  XTrain = [];
  YTrain = categorical([]);
  t = 1;
  for i =1:length(Bacteria_Names)
    i
    load(dataFileNames{i})
    XTrain(:,:,1,t:t+size(A1,3)-1) = A1(50-midCropAtRead/2+1:50+midCropAtRead/2,50-midCropAtRead/2+1:50+midCropAtRead/2,:);
    YTrain(      t:t+size(A1,3)-1) = Bacteria_Names{i};
    t = t+size(A1,3);
  end  
  XTrain    = imresize(XTrain,[pram.Nx pram.Nx]);
  
  N_trTot   = length(YTrain);
  N_val     = round(N_trTot*pram.ValDataRatio);
  
  rng(1);
  randInds  = randperm(N_trTot);
  YTrain    = YTrain(randInds);
  XTrain    = XTrain(:,:,:,randInds);
  
  XVal      = XTrain(:,:,:,1:N_val);
  YVal      = YTrain(:,1:N_val);
  XTr       = XTrain(:,:,:,N_val+1:end); 
  YTr       = YTrain(:,N_val+1:end);     
end


