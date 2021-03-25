

function ds       = readData_rcnn(pram)           
   
  In_imds_dir     = fullfile('./Imds');
  Out_imds_dir    = fullfile('./Pxds');
  In_imds         = imageDatastore(In_imds_dir ,'ReadFcn', @subf_readRescale5k );
  
  
  L_imds          = imageDatastore(Out_imds_dir,'ReadFcn', @subf_readAnnotation);
  L               = L_imds.readall;
  
  for i=1:length(L)
    L_now         = L{i};
    stats         = regionprops(L_now,'Centroid');
    centroids_fg  = vertcat(stats(:).Centroid);    
    
    outInds       = find(centroids_fg(:,1)<pram.Nx |...
                         centroids_fg(:,1)>2000 - pram.Nx | ...
                         centroids_fg(:,2)<pram.Nx |...
                         centroids_fg(:,2)>2000 - pram.Nx);
    centroids_fg(outInds,:) = [];
                       
    N_fg          = size(centroids_fg,1);
    foci{i,1}     = cat(2,round(centroids_fg)-pram.Nx/2,ones(size(centroids_fg))*pram.Nx);
  end
  blds            = boxLabelDatastore(table(foci));    
  ds              = combine(In_imds, blds);
       
%   I.tr          = subf_normalize_tissue_to_1(In_imds.readall);
%   
%   
%   In_imds_dir   = fullfile('./Imds_test');
%   Out_imds_dir  = fullfile('./Pxds_test');
%   In_imds       = imageDatastore(In_imds_dir,'ReadFcn', @subf_readRescale5k );
%   L_imds        = imageDatastore(Out_imds_dir,'ReadFcn',@subf_readAnnotation);
%   I.test        = subf_normalize_tissue_to_1(In_imds.readall);
%   L.test        = subf_dialate_labels       (L_imds.readall );
%   
%   % make file name stems for saving results
%   for i = 1:length(In_imds.Files)         
%     temp            = find(In_imds.Files{i}=='/');temp=temp(end);  
%     I.testNames{i}  = In_imds.Files{i}(temp+1:end-4);
%   end
 
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
  r_max = 10;
  se    = strel('disk',r_max);
  for i = 1:length(L)
    
    BW2 = imdilate(BW,se);
  
  end
end

function I = subf_readRescale5k(filename) 
  I0  = imread(filename);
  if size(I0,3)>1
   I0 = sum(I0,3);
  end
  I0  = single(I0)/5000;
  I(:,:,3) = I0(1:2000,1:2000);
  I(:,:,2) = I0(1:2000,1:2000);
  I(:,:,1) = I0(1:2000,1:2000);    
end    

function L = subf_readAnnotation(filename)
  I0   = imread(filename);
  if size(I0,3)>1
   I0 = mean(I0,3);
  end
  % th = (max(I0(:)) + min(I0(:)))/2 ; % half therhold is not ideal it meges some objects together
  th   = min(I0(:)) + (max(I0(:)) - min(I0(:)))/10;
  L    = I0>th;

  if sum(L(:)==0) < sum(L(:)==1)
   L = ~ L;
  end       
  L = L(1:2000,1:2000);
end


