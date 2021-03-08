

function [I L] = readData(pram)

  Nx            = pram.Nx;
  
  In_imds_dir   = fullfile('./Imds');
  Out_imds_dir  = fullfile('./Pxds');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  L_imds        = imageDatastore(Out_imds_dir,'ReadFcn',@readAnnotation);

  I.tr          = subf_normalize_tissue_to_1(In_imds.readall);
  L.tr          = L_imds.readall;
  
  In_imds_dir   = fullfile('./Imds_test');
  Out_imds_dir  = fullfile('./Pxds_test');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  L_imds        = imageDatastore(Out_imds_dir,'ReadFcn',@readAnnotation);
  I.test        = subf_normalize_tissue_to_1(In_imds.readall);
  L.test        = L_imds.readall;
  
  % normalize intensity to tissue -> 1 count
  
  % make file name stems for saving results
  for i = 1:length(In_imds.Files)
    temp                = find(In_imds.Files{i}=='/');temp=temp(end);  
    I.test_nameStem{i}  = In_imds.Files{i}(temp+1:end-4);
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

    
