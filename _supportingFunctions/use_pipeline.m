
function use_pipeline(net_rpn,net_rcn,pram)

  Nx            = pram.Nx;
  mkdir(['./results/' date '/figs/']);
  
  In_imds_dir   = fullfile(pram.UseDataDir);
  Out_imds_dir  = fullfile(pram.UseDataDir);
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  Out_imds      = imageDatastore(Out_imds_dir);
    
  th_prop       = pram.th_prop; % This is not good. We should try to make the propsal net work better
  I_proposals   = [];

  for i=1:size(In_imds.Files,1)
      i
      [I_now,fileinfo] = readimage(In_imds,i);

      temp = find(fileinfo.Filename=='/');temp=temp(end);
      fileNameStem = fileinfo.Filename(temp+1:end-4);

      [L_fg I_now Area_tissue_now L_now] = segmentTissueOtsu(I_now,[],Nx);

      L_proposal = apply_proposal_net(net_rpn,I_now,Nx);
      L_proposal(find(L_fg==0))=0;
      [I_proposals_now centroids Y_gt_now] = genRegionProposals(L_proposal>th_prop,[],I_now,Nx);

      [YPred,scores] = classify(net_rcn,I_proposals_now);

      Count(i,1) = sum(YPred=='1');
      Filename{i,1} = fileinfo.Filename(temp+1:end);
      Area_tissue(i,1) = Area_tissue_now; 

      centroids_positives  = centroids(find(YPred=='1'),:);

      h = imagesc(I_now,[0 2.5]);hold on
      plot(centroids_positives(:,1),centroids_positives(:,2),'+g','MarkerSize',10,'LineWidth',1);
      hold off
      truesize
      saveas(h,['./results/' date '/figs/' fileNameStem '_fig.jpeg']);   
  end
  
  results_table = table(Filename,Count,Area_tissue);
  writetable(results_table,['./results/' date 'run_' date '.xls']);
  
end

