
function [BW I A BW_foci] = segmentTissueOtsu(I0,BW_foci,Nx)
    
     imresize_factor = 0.1;   
     [I0 scaleFactor] = normalize_tissue_to_1(I0);
     I = imresize(I0,imresize_factor);% resize by 1/10 times to process easily
     
     
     I(find(I(:)>2))=2;   
     
     BW = imbinarize(I,graythresh(I));
     BW = imfill(BW,'holes');
     L = bwlabel(BW);   
     
     stats = regionprops(L,'Area');
     AreaList = vertcat(stats.Area);
     [A mxid] = max(AreaList);
     
     BW = (L==mxid);
     BW = imresize(BW,size(I0));   
     
     SE = strel('disk',20);
     BW = imerode(BW,SE);   
     
     L = bwlabel(BW);   
     stats = regionprops(L,'Area');
     AreaList = vertcat(stats.Area);
     [A mxid] = max(AreaList);
     BW = (L==mxid);
     
          
     stats = regionprops(BW,'BoundingBox');
     bbox = round(stats.BoundingBox);
          
%      bbox_r_range = max(bbox(2)-Nx,1):min(bbox(2)+bbox(4)+Nx,size(I0,1));
%      bbox_c_range = max(bbox(1)-Nx,1):min(bbox(1)+bbox(3)+Nx,size(I0,2));

     if bbox(2)-Nx<1 || bbox(1)-Nx<1 || bbox(4)+Nx>size(I0,1) || bbox(3)+Nx>size(I0,2)
        BW = padarray(BW,[Nx Nx]);
        I = padarray(I,[Nx Nx]);        
        if ~isempty(BW_foci)     
            BW_foci = padarray(BW_foci,[Nx Nx]);
        end
        bbox(1:2) = bbox(1:2)+Nx;
     end     
     bbox_r_range = bbox(2)-Nx:bbox(2)+bbox(4)+Nx;
     bbox_c_range = bbox(1)-Nx:bbox(1)+bbox(3)+Nx;
     
     BW = BW(bbox_r_range,bbox_c_range);
     I  = I0(bbox_r_range,bbox_c_range);
     if ~isempty(BW_foci)         
         BW_foci = BW_foci(bbox_r_range,bbox_c_range);
     end
end



