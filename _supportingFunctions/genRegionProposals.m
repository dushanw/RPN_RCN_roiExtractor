% note 2021-03-05 there's a problem with missing false negatives at the
% region proposal stage. !! fix it!!


function [I_proposals Centroids Y_gt centroids_fn_rpn] = genRegionProposals(L,L_gt,I0,Nx)
    
%   LL(:,:,1) = I0;
%   LL(:,:,2) = L;
%   LL(:,:,3) = L_gt;
%   imagesc(LL)

  L = bwmorph(L,'clean');
  L = bwmorph(L,'close');
  if Nx>32                   % this is bad practice. See if tissue level works without opening.
   L = bwmorph(L,'open');
  else                       % seems like it doesnt work without the opening
   SE = strel('disk',1,8);
   L  = imopen(L,SE);       % similar style: L = imclose(L,SE)
  end

  I_proposals           = [];
  Centroids             = [];
  Y_gt                  = [];
  centroids_fn_rpn      = [];

  if ~isempty(L_gt)
    %% region overlap method      
%         L_added           = single(L)+single(L_gt)*2;
%         stats             = regionprops(L_added>0,L_added,'Area','Centroid','MaxIntensity');
%         inds_fn_rpn       = find(vertcat(stats.MaxIntensity)==2);
%         centroids_fn_rpn  = vertcat(stats(inds_fn_rpn).Centroid);
%         
%         stats_proposals   = regionprops(L,L_added,'Area','Centroid','MaxIntensity');
%
%         Centroids         = cat(1,stats_proposals.Centroid);
%         Y_gt              = vertcat(stats.MaxIntensity)==3;


    %% distance method to identify positives
    stats_proposals   = regionprops(L   ,'Centroid');
    stats_gt          = regionprops(L_gt,'Centroid');

    centr_proposals   = cat(1,stats_proposals.Centroid);
    centr_gt          = cat(1,stats_gt.Centroid);

    if ~isempty(centr_gt)
      Dist_mat          =  sqrt((centr_proposals(:,1) - centr_gt(:,1)').^2 + ...
                                (centr_proposals(:,2) - centr_gt(:,2)').^2);
      [min_dist gt_ind] = min(Dist_mat,[],2);        
      Centroids         = centr_proposals;
      Y_gt              = min_dist<5;
    else
      Centroids         = centr_proposals;
      Y_gt              = zeros(size(Centroids,1),1);          
    end
  else
    stats_proposals   = regionprops(L,'Area','Centroid');
    Centroids         = cat(1,stats_proposals.Centroid);
    Y_gt              = [];
  end

  % remove proposals close to the boundary (from more than Nx/2)
  idx_valid  = (Centroids(:,1) >= Nx/2+1) & ...
               (Centroids(:,2) >= Nx/2+1) & ...
               (Centroids(:,1) <= size(I0,1) - Nx/2 +1) & ...
               (Centroids(:,2) <= size(I0,2) - Nx/2 +1)
  Centroids  = Centroids(idx_valid,:);
  Y_gt       = Y_gt(idx_valid);
             
  for k=1:size(Centroids,1)
    c = round(Centroids(k,1));          
    r = round(Centroids(k,2));

    I_proposals(:,:,1,k) = I0(r-Nx/2:r+Nx/2-1,c-Nx/2:c+Nx/2-1);
  end
end

    
    
    