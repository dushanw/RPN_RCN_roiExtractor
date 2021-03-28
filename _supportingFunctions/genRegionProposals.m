% note 2021-03-05 there's a problem with missing false negatives at the
% region proposal stage. !! fix it!!


function [I_proposals centr_proposals Y_gt centroids_fn_rpn] = genRegionProposals(L_prop,L_gt,I0,pram)
    
  Nx      = pram.Nx;
  
  L_prop  = bwmorph(L_prop,'clean');
  L_prop  = bwmorph(L_prop,'close');
  if Nx>32                   % this is bad practice. See if tissue level works without opening.
   L_prop = bwmorph(L_prop,'open');
  else                       % seems like it doesnt work without the opening
   SE     = strel('disk',1,8);
   L_prop = imopen(L_prop,SE);       % similar style: L = imclose(L,SE)
  end

  I_proposals         = [];
%   centr_proposals     = [];
%   Y_gt                = [];
%   centroids_fn_rpn    = [];

  [centr_proposals,...
  Y_gt,...
  centroids_fn_rpn] = f_match_propBW_2_gtBW(L_prop,L_gt,pram);

  % remove proposals close to the boundary (from more than Nx/2)
  if ~isempty(centr_proposals)
%     idx_valid  = (Centroids(:,1) >= Nx/2+1) & ...
%                  (Centroids(:,2) >= Nx/2+1) & ...
%                  (Centroids(:,1) <= size(I0,2) - Nx/2 +1) & ...
%                  (Centroids(:,2) <= size(I0,1) - Nx/2 +1);
%     Centroids  = Centroids(idx_valid,:);
%     Y_gt       = Y_gt(idx_valid);

    for k=1:size(centr_proposals,1)
      c = round(centr_proposals(k,1));          
      r = round(centr_proposals(k,2));

      I_proposals(:,:,:,k) = I0(r-Nx/2:r+Nx/2-1,c-Nx/2:c+Nx/2-1,:);
    end
  end
  
end

    
    
    