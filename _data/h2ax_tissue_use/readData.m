

function I = readData(pram)
   
  In_imds_dir   = fullfile('./Imds_use');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn', @subf_readRescale5k );
  I.use         = subf_normalize_tissue_to_1(In_imds.readall);
  
  % make file name stems for saving results
  for i = 1:length(In_imds.Files)
    temp            = find(In_imds.Files{i}=='/');temp=temp(end);  
    I.useNames{i}   = In_imds.Files{i}(temp+1:end-4);
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
       th   = (max(I0(:)) + min(I0(:)))/2 ;
       L    = I0>th;
       
       if sum(L(:)==0) < sum(L(:)==1)
         L = ~ L;
       end       
end
