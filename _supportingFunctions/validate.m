
function validate(net_rpn,net_rcn,pram)

  Nx            = pram.Nx;
  mkdir(['./results/' date '/figs/']);
  
  In_imds_dir   = fullfile(pram.TrDataDir,'Imds_val');
  Out_imds_dir  = fullfile(pram.TrDataDir,'Pxds_val');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  Out_imds      = imageDatastore(Out_imds_dir,'ReadFcn',@readAnnotation);
    
  th_prop       = pram.th_prop; % This is not good. We should try to make the propsal net work better
  I_proposals   = [];

  for i=1:size(In_imds.Files,1)
      i
      [I_now,fileinfo] = readimage(In_imds,i);
      L_now = readimage(Out_imds,i);

      temp = find(fileinfo.Filename=='/');temp=temp(end);
      fileNameStem = fileinfo.Filename(temp+1:end-4);

      [L_fg I_now Area_tissue_now L_now] = segmentTissueOtsu(I_now,L_now,Nx);
            
      if pram.runTissueSeg == 1      
        [L_fg I_now Area_tissue_now L_now] = segmentTissueOtsu(I_now,L_now,Nx);% segments the tissue foreground 
      else
        I_now           = normalize_tissue_to_1(I_now);
        L_fg            = ones(size(L_now))>0;
        L_fg            = padarray(L_fg,[Nx Nx]);
        L_now           = padarray(L_now,[Nx Nx]);
        I_now           = padarray(I_now,[Nx Nx]);
        Area_tissue_now = -1;
      end
      
      L_proposal = apply_proposal_net(net_rpn,I_now,Nx);
      L_proposal(find(L_fg==0))=0;
      [I_proposals_now centroids Y_gt_now] = genRegionProposals(L_proposal>th_prop,L_now,I_now,Nx);

      [YPred,scores] = classify(net_rcn,I_proposals_now);

      Count(i,1) = sum(YPred=='1');
      Filename{i,1} = fileinfo.Filename(temp+1:end);
      Area_tissue(i,1) = Area_tissue_now; 

      centroids_tp    = centroids(find(YPred=='1' & Y_gt_now==1),:);
      centroids_fp    = centroids(find(YPred=='1' & Y_gt_now==0),:);
      centroids_fn    = centroids(find(YPred=='0' & Y_gt_now==1),:);
      h = imagesc(I_now,[0 2.5]);hold on
      plot(centroids_tp(:,1),centroids_tp(:,2),'+g','MarkerSize',10,'LineWidth',1);    
      plot(centroids_fp(:,1),centroids_fp(:,2),'+r','MarkerSize',10,'LineWidth',1);    
      plot(centroids_fn(:,1),centroids_fn(:,2),'+b','MarkerSize',10,'LineWidth',1);    
      hold off
      truesize
      saveas(h,['./results/' date '/figs/' fileNameStem '_fig.jpeg']);   
  end

end