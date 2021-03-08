

function [XTr, YTr, XVal, YVal] = gen_tr_data_RPN(I,L,pram)

  Nx  = pram.Nx; 
  k   = 0;
  for i=1:length(I)
      i
      L_now = L{i};
      I_now = I{i};

      if pram.runTissueSeg == 1      
        [L_fg I_now A L_now] = segmentTissueOtsu(I_now,L_now,Nx);% segments the tissue foreground 
      else        
        L_fg  = ones(size(L_now))>0;
        L_fg  = padarray(L_fg,[Nx Nx]);
        L_now = padarray(L_now,[Nx Nx]);
        I_now = padarray(I_now,[Nx Nx]);
        A     = -1;
      end

      stats = regionprops(L_now,'Centroid');
      centroids_fg = vertcat(stats(:).Centroid);
      N_fg = size(centroids_fg,1);

      centroids_bg_temp = find(L_now==0 & L_fg==1);
      centroids_bg_temp = centroids_bg_temp(randi(length(centroids_bg_temp),[N_fg*5 1]));
      [r c] = ind2sub(size(L_now),centroids_bg_temp);
      clear centroids_bg
      centroids_bg(:,1) = c;
      centroids_bg(:,2) = r;

      for j=1:size(centroids_fg,1)
          Ic = I_now(centroids_fg(j,2)-Nx/2:centroids_fg(j,2)+Nx/2-1,...
                     centroids_fg(j,1)-Nx/2:centroids_fg(j,1)+Nx/2-1);

          k = k+1;
          XTrain(:,:,1,k)=Ic;
          YTrain(k)=1;
      end

      for j=1:size(centroids_bg,1)
          Ic = I_now(centroids_bg(j,2)-Nx/2:centroids_bg(j,2)+Nx/2-1,...
                     centroids_bg(j,1)-Nx/2:centroids_bg(j,1)+Nx/2-1);

          k = k+1;
          XTrain(:,:,1,k)=Ic;
          YTrain(k)=0;
      end    
  end
  
  N_trTot   = length(YTrain);
  N_val     = round(N_trTot*pram.ValDataRatio);
  
  randInds  = randperm(N_trTot);
  YTrain    = YTrain(randInds);
  XTrain    = XTrain(:,:,1,randInds);    
  YTrain    = categorical(YTrain);
  
  XVal = XTrain(:,:,:,1:N_val);
  YVal = YTrain(:,1:N_val);
  XTr  = XTrain(:,:,:,N_val+1:end); 
  YTr  = YTrain(:,N_val+1:end); 
end


