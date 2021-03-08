% note 2021-03-05 there's a problem with missing false negatives at the
% region proposal stage. !! fix it!!


function [I_proposals Centroids Y_gt centroids_fn_rpn] = genRegionProposals(L,L_gt,I0,Nx)
    
    L = bwmorph(L,'clean');
    L = bwmorph(L,'close');
    L = bwmorph(L,'open');
    
    if ~isempty(L_gt)
        L_added           = single(L)+single(L_gt)*2;
        stats             = regionprops(L_added>0,L_added,'Area','Centroid','MaxIntensity');
        inds_fn_rpn       = find(vertcat(stats.MaxIntensity)==2);
        centroids_fn_rpn  = vertcat(stats(inds_fn_rpn).Centroid);
        
        stats             = regionprops(L,L_added,'Area','Centroid','MaxIntensity');
        Y_gt              = vertcat(stats.MaxIntensity)==3;
    else
        stats   = regionprops(L,'Area','Centroid');
        Y_gt    = [];
    end
       
    I_proposals = [];
    for k=1:length(stats)
        c = round(stats(k,1).Centroid(1));          
        r = round(stats(k,1).Centroid(2));
        Centroids(k,1)=c;
        Centroids(k,2)=r;
        
        I_proposals(:,:,1,k) = I0(r-Nx/2:r+Nx/2-1,c-Nx/2:c+Nx/2-1);
    end
end

    
    
    