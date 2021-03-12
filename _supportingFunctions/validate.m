
function validate(Itest,Ltest,nameStem_test,net_rpn,net_rcn,pram)

  Nx            = pram.Nx;
  mkdir(['./results/' date '/figs/']);
      
  th_prop       = pram.th_prop; % This is not good. We should try to make the propsal net work better
  I_proposals   = [];

  for i=1:length(Itest)
      i
      I_now             = Itest{i};
      L_now             = Ltest{i};     
      fileNameStem      = nameStem_test{i};
            
      %% dataset specific preprocessing
      switch pram.experimentType
        case 'h2ax_cells'   
          Area_tissue_now   = -1;                    
          L_proposal        = apply_proposal_net(net_rpn,I_now,Nx);                    
          [I_proposals_now ...
           centroids ...
           Y_gt_now ...
           centroids_fn_rpn]= genRegionProposals(L_proposal>th_prop,L_now,I_now,Nx);         
          if ~isempty(I_proposals_now)
            [YPred,scores]  = classify(net_rcn,I_proposals_now);            
            % remove the extra boder included in input cell cropping          
            centroids         = centroids(centroids(:,1) > Nx/2 & ...
                                          centroids(:,2) > Nx/2 & ...                                           
                                          centroids(:,1) < size(I_now,2) - Nx/2 & ...
                                          centroids(:,2) < size(I_now,1) - Nx/2, :);
          else
            YPred           = [];            
          end
        case 'h2ax_tissue'  
          if pram.runTissueSeg == 1      
            [L_fg I_now Area_tissue_now L_now] = segmentTissueOtsu(I_now,L_now,Nx);% segments the tissue foreground 
          else
            L_fg            = ones(size(L_now))>0;
            L_fg            = padarray(L_fg,[Nx Nx]);
            L_now           = padarray(L_now,[Nx Nx]);
            I_now           = padarray(I_now,[Nx Nx]);
            Area_tissue_now = -1;
          end                    
          L_proposal        = apply_proposal_net(net_rpn,I_now,Nx);
          L_proposal(find(L_fg==0))=0;

          [I_proposals_now ...
           centroids ...
           Y_gt_now ...
           centroids_fn_rpn]= genRegionProposals(L_proposal>th_prop,L_now,I_now,Nx);

          if ~isempty(I_proposals_now)
            [YPred,scores]  = classify(net_rcn,I_proposals_now);
          else
            YPred           = [];
          end
      end
            
      centroids_tp      = centroids(find(YPred=='1' & Y_gt_now==1),:);
      centroids_fp      = centroids(find(YPred=='1' & Y_gt_now==0),:);
      centroids_fn      = centroids(find(YPred=='0' & Y_gt_now==1),:);
      
      % counting restuls      
      Filename{i,1}     = fileNameStem;
      Area_tissue(i,1)  = Area_tissue_now;
      
      TPs(i,1)          = size(centroids_tp,1);
      FPs(i,1)          = size(centroids_fp,1);
      FNs(i,1)          = size(centroids_fn,1) + size(centroids_fn_rpn,1);
      FNs_rpn(i,1)      = size(centroids_fn_rpn,1);
      
      Counts(i,1)       = TPs(i,1) + FPs(i,1);
      Counts_gt(i,1)    = TPs(i,1) + FNs(i,1);
      Accuracy(i,1)     = TPs(i,1)/(TPs(i,1)+FPs(i,1)+FNs(i,1));
      Precision(i,1)    = TPs(i,1)/(TPs(i,1)+FPs(i,1)         );
      Recall(i,1)       = TPs(i,1)/(TPs(i,1)         +FNs(i,1));
      
      % plot on the image
      centroids_fn_rpn = cat(1,centroids_fn_rpn,[1 1]);% to avoid trying to plot empty array
      centroids_tp     = cat(1,centroids_tp    ,[1 1]);
      centroids_fp     = cat(1,centroids_fp    ,[1 1]);
      centroids_fn     = cat(1,centroids_fn    ,[1 1]);
                        
      h = figure('WindowState','maximized');
      imagesc(I_now);axis image;hold on;colorbar
      plot(centroids_tp(:,1)    ,centroids_tp(:,2)    ,'+g','MarkerSize',30,'LineWidth',1);    
      plot(centroids_fn(:,1)    ,centroids_fn(:,2)    ,'+r','MarkerSize',30,'LineWidth',1);
      plot(centroids_fp(:,1)    ,centroids_fp(:,2)    ,'+w','MarkerSize',30,'LineWidth',1);    
      plot(centroids_fn_rpn(:,1),centroids_fn_rpn(:,2),'+m','MarkerSize',30,'LineWidth',1);    
      hold off
      % truesize
      saveas(h,['./results/' date '/figs/' fileNameStem '_fig.jpeg']);   
      
  end
  results_table         = table(Filename,...
                                Counts,Counts_gt,Area_tissue,...
                                Accuracy,Precision,Recall,...
                                TPs,FPs,FNs,FNs_rpn);
  writetable(results_table,['./results/' date '/run_' date '.xls']);

end







