
function [I_proposals Centroids Y_gt] = genRegionProposals(L,L_gt,I0,Nx)
    
    L = bwmorph(L,'clean');
    L = bwmorph(L,'close');
    L = bwmorph(L,'open');
    
    if ~isempty(L_gt)
        L_added = single(L)+single(L_gt);    
        stats = regionprops(L,L_added,'Area','Centroid','MaxIntensity');
        Y_gt = vertcat(stats.MaxIntensity)==2;  
    else
        stats = regionprops(L,'Area','Centroid');
        Y_gt = [];
    end
       
    for k=1:length(stats)
        c = round(stats(k,1).Centroid(1));          
        r = round(stats(k,1).Centroid(2));
        Centroids(k,1)=c;
        Centroids(k,2)=r;
        
        I_proposals(:,:,1,k) = I0(r-Nx/2:r+Nx/2-1,c-Nx/2:c+Nx/2-1);
    end
end

    
    
    