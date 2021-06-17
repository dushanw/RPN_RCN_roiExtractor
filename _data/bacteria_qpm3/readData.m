
function [XTr, YTr, XVal, YVal] = readData(pram)
  
  Bacteria_Names = {'Ecoli_101',...
                    'Ecoli_102',...
                    'Ecoli_104',...
                    'Kpneumoniae_211',...
                    'Kpneumoniae_212',...
                    'Kpneumoniae_240'};

  dataFileNames  = {'./Ecoli_101_06.mat',...
                    './Ecoli_102_07.mat',...
                    './Ecoli_104_08.mat',...
                    './K.pneumoniae_211_10.mat',...
                    './K.pneumoniae_212_11.mat',...
                    './K.pneumoniae_240_12.mat'};
  midCropAtRead  = 32;                                      % original image are of 100x100 but the object is in a smaller region in the middle.
                  
  XTrain = [];
  YTrain = categorical([]);
  t = 1;
  for i =1:length(Bacteria_Names)
    i
    load(dataFileNames{i})
    if exist('B1')
      B = {B1{:}, B2{:}};
    end
    
    for j = 1:length(B)
      temp                            = B{j};
      XTrain(:,:,1,t:t+size(temp,3)-1)= temp(50-midCropAtRead/2+1:50+midCropAtRead/2,...
                                             50-midCropAtRead/2+1:50+midCropAtRead/2,:);
      YTrain(      t:t+size(temp,3)-1)= Bacteria_Names{i};
      t = t+size(temp,3);      
    end    
    clear B B1 B2
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


