

function [I L] = readData(pram)           
 
  In_imds_dir   = fullfile('./Imds');
  Out_imds_dir  = fullfile('./Pxds');
  In_imds       = imageDatastore(In_imds_dir ,'ReadFcn', @subf_readRescale5k );
  L_imds        = imageDatastore(Out_imds_dir,'ReadFcn', @subf_readAnnotation);

  I.tr          = resizeAll(subf_normalize_tissue_to_1(In_imds.readall),pram);
  L.tr          = resizeAll(subf_dialate_labels       (L_imds.readall ),pram);
  
  In_imds_dir   = fullfile('./Imds_test');
  Out_imds_dir  = fullfile('./Pxds_test');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn', @subf_readRescale5k );
  L_imds        = imageDatastore(Out_imds_dir,'ReadFcn',@subf_readAnnotation);
  
  I.test        = resizeAll(subf_normalize_tissue_to_1(In_imds.readall),pram);
  L.test        = resizeAll(subf_dialate_labels       (L_imds.readall ),pram);
  
  % make file name stems for saving results
  for i = 1:length(In_imds.Files)         
    temp            = find(In_imds.Files{i}=='/');temp=temp(end);  
    I.testNames{i}  = In_imds.Files{i}(temp+1:end-4);
  end
 
end

function I = resizeAll(I,pram)
  for i = 1:length(I)  
    I{i} = imresize(I{i},pram.imreasizeFactor);     
  end
end

function I = subf_normalize_tissue_to_1(I)

  for i = 1:length(I)  
    intensity_range = linspace(0,max(I{i}(:)),500);
    hist_I = hist(I{i}(:),intensity_range);

    [pks locs] = findpeaks(hist_I);
    % locs(find(pks<1e6))=[];
    % intensity_tissue = intensity_range(locs(2));% second peak is the tissue

    [sorted_pks sorted_inds] = sort(pks,'descend');
    intensity_tissue = intensity_range(locs(sorted_inds(2)));% second peak is the tissue

    I{i} = I{i}/intensity_tissue;
  end
  
end

function L = subf_dialate_labels(L)
%   r_max = 10;
%   se    = strel('disk',r_max);
%   for i = 1:length(L)    
%     L{i} = imdilate(L{i},se);  
%   end
end

function I = subf_readRescale5k(filename) 
       I0 = imread(filename);
       if size(I0,3)>1
         I0 = sum(I0,3);
       end
       I = single(I0)/5000;        
end    

function L = subf_readAnnotation(filename)
       I0   = imread(filename);
       if size(I0,3)>1
         I0 = mean(I0,3);
       end
       % th = (max(I0(:)) + min(I0(:)))/2 ; % half therhold is not ideal it meges some objects together
       th   = min(I0(:)) + (max(I0(:)) - min(I0(:)))/10
       L    = I0>th;
       
       if sum(L(:)==0) < sum(L(:)==1)
         L = ~ L;
       end       
end
