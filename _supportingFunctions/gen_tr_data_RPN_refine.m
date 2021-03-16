
function [XTr, YTr, XVal, YVal] = gen_tr_data_RPN_refine(I,L,net_RPN,pram)

  Nx  = pram.Nx; 
  k   = 0;
  for i=1:length(I)
    i
    L_now = L{i};
    I_now = I{i};

    %% preprocess
    if pram.runTissueSeg == 1      
      [L_fg I_now A L_now] = segmentTissueOtsu(I_now,L_now,Nx);% segments the tissue foreground 
    else        
      L_fg  = ones(size(L_now))>0;
      L_fg  = padarray(L_fg,[Nx Nx]);
      L_now = padarray(L_now,[Nx Nx]);
      I_now = padarray(I_now,[Nx Nx]);
      A     = -1;
    end

    %% extract postives (ground truth)
    stats         = regionprops(L_now,'Centroid');
    centroids_fg  = vertcat(stats(:).Centroid);
    N_fg          = size(centroids_fg,1);

    %% extract targetted negatives
    L_proposal    = apply_proposal_net(net_RPN,I_now,Nx);
    L_proposal    = L_proposal > pram.th_prop;
    L_diff        = ( L_proposal - (L_proposal & L_now) ) & L_fg;

%   % only selecets the centroids in the error regions
%   stats         = regionprops(L_diff,'Centroid'); 
%   centroids_bg  = vertcat(stats(:).Centroid);
    
    % slect more pixels on the error regions
    L_diff        = (bwmorph(L_diff,'skel',Inf)); % skeletonize L_diff    
    inds_tgt      = find(L_diff==1);
    [r c]         = ind2sub(size(L_diff),inds_tgt);    
    centroids_bg  = [c r];
    
    
    %% extract random negatives
    centroids_rnd = find(L_now==0 & L_fg==1);
    centroids_rnd = centroids_rnd(randi(length(centroids_rnd),[N_fg 1]));
    [r c]         = ind2sub(size(L_now),centroids_rnd);    
    centroids_bg  = cat(1,centroids_bg,[c r]);
    
      
    %% crop image locations
    for j=1:size(centroids_fg,1)
        Ic = I_now(centroids_fg(j,2)-Nx/2:centroids_fg(j,2)+Nx/2-1,...
                   centroids_fg(j,1)-Nx/2:centroids_fg(j,1)+Nx/2-1,:);

        k = k+1;
        XTrain(:,:,:,k)=Ic;
        YTrain(k)=1;                    
    end

    for j=1:size(centroids_bg,1)
        Ic = I_now(centroids_bg(j,2)-Nx/2:centroids_bg(j,2)+Nx/2-1,...
                   centroids_bg(j,1)-Nx/2:centroids_bg(j,1)+Nx/2-1,:);

        k = k+1;
        XTrain(:,:,:,k)=Ic;
        YTrain(k)=0;
    end    
  end
  
  N_trTot   = length(YTrain);
  N_val     = round(N_trTot*pram.ValDataRatio);
  
  randInds  = randperm(N_trTot);
  YTrain    = YTrain(randInds);
  XTrain    = XTrain(:,:,:,randInds);    
  YTrain    = categorical(YTrain);
  
  XVal = XTrain(:,:,:,1:N_val);
  YVal = YTrain(:,1:N_val);
  XTr  = XTrain(:,:,:,N_val+1:end); 
  YTr  = YTrain(:,N_val+1:end); 
end

