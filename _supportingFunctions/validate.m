
function results_table = validate(Itest,Ltest,nameStem_test,net_rpn,net_rcn,pram)
  
  resDir        = sprintf('./results/%s/%s_%s_%d/',...
                                     date,...             
                                        pram.experimentType,...
                                           pram.dataset,...
                                              pram.Nx)
  mkdir([resDir '/figs_rpn/']);
  mkdir([resDir '/figs_rcn/']);
  
  Nx            = pram.Nx;
  th_prop       = pram.th_prop; % This is not good. We should try to make the propsal net work better
  for i=1:length(Itest)
      i
      I_now             = Itest{i};
      L_now             = Ltest{i};     
      fileNameStem      = nameStem_test{i};
            
      %% dataset specific preprocessing <temporaly commented on 23-03-2021>
%       switch pram.experimentType                
%         case 'nuc_tissue' 
%           L_now             = padarray(L_now,[Nx Nx]);            
%           I_now             = padarray(I_now,[Nx Nx]);
%           Area_tissue_now   = -1;                    
%           L_proposal        = apply_proposal_net(net_rpn,I_now,Nx);
%           
%           % temp 20210313 for nuc_tissue dataset
%           savedir  = '~/Documents/tempData/';
%           savename = sprintf('temp_var_%d.mat',i);
%           save([savedir savename],'L_proposal','I_now','L_now');
%           % end temp
%           
%           
%           [I_proposals_now ...
%            centroids ...
%            Y_gt_now ...
%            centroids_fn_rpn]= genRegionProposals(L_proposal>th_prop,L_now,I_now,Nx,pram);
%           if ~isempty(I_proposals_now)
%             [YPred,scores]  = classify(net_rcn,I_proposals_now);
%             % remove the extra boder included in input cell cropping (this is a repeat as donee in genRegProposal func)         
%             inds_on_cell    = [centroids(:,1) > Nx/2 & ...
%                                centroids(:,2) > Nx/2 & ...                                           
%                                centroids(:,1) < size(I_now,2) - Nx/2 & ...
%                                centroids(:,2) < size(I_now,1) - Nx/2 ];     
%             centroids       = centroids(inds_on_cell,:);
%             YPred           = YPred    (inds_on_cell);
%           else
%             YPred           = [];            
%           end                              
%         case 'h2ax_cells'   
%           Area_tissue_now   = -1;
%           L_proposal        = apply_proposal_net(net_rpn,I_now,Nx);
%           [I_proposals_now ...
%            centroids ...
%            Y_gt_now ...
%            centroids_fn_rpn]= genRegionProposals(L_proposal>th_prop,L_now,I_now,Nx,pram);
%           if ~isempty(I_proposals_now)
%             [YPred,scores]  = classify(net_rcn,I_proposals_now);
%             % remove the extra boder included in input cell cropping (this is a repeat as donee in genRegProposal func)         
%             inds_on_cell    = [centroids(:,1) > Nx/2 & ...
%                                centroids(:,2) > Nx/2 & ...                                           
%                                centroids(:,1) < size(I_now,2) - Nx/2 & ...
%                                centroids(:,2) < size(I_now,1) - Nx/2 ];     
%             centroids       = centroids(inds_on_cell,:);
%             YPred           = YPred    (inds_on_cell);
%           else
%             YPred           = [];            
%           end
%         case 'h2ax_tissue'  

      %% process using rpn and rcn
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
       centroids_fn_rpn]= genRegionProposals(L_proposal>th_prop,L_now,I_now,pram);
     
      if ~isempty(I_proposals_now)
        [YPred,scores]  = classify(net_rcn,I_proposals_now);
      else
        YPred           = [];
      end
            
      %% remove objects in the boundary (withon a 2*Nx range)
      limXs       = 2*Nx;
      limYs       = 2*Nx;
      limXe       = size(I_now,2) - 2*Nx;
      limYe       = size(I_now,1) - 2*Nx;      
      
      idx_valid         = centroids(:,1) >= limXs & centroids(:,2) >= limYs & ...
                          centroids(:,1) <= limXe & centroids(:,2) <= limYe;
      centroids         = centroids(idx_valid,:);
      YPred             = YPred(idx_valid);
      Y_gt_now          = Y_gt_now(idx_valid);
      
      idx_valid         = centroids_fn_rpn(:,1) >= limXs & centroids_fn_rpn(:,2) >= limYs & ...
                          centroids_fn_rpn(:,1) <= limXe & centroids_fn_rpn(:,2) <= limYe;
      centroids_fn_rpn  = centroids_fn_rpn(idx_valid,:);
      
      %% analyse results
      centroids_tp      = centroids(find(YPred=='1' & Y_gt_now==1),:);
      centroids_fp      = centroids(find(YPred=='1' & Y_gt_now==0),:);
      centroids_fn      = centroids(find(YPred=='0' & Y_gt_now==1),:);
      centroids_fn_rpn  = centroids_fn_rpn;
     
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
      
      %% plot rcn figures      
      h = figure('WindowState','maximized');
      clear I_plot
            
      centroids_fn_rpn  = cat(1,centroids_fn_rpn,[1 1]);% to avoid trying to plot empty array
      centroids_tp      = cat(1,centroids_tp    ,[1 1]);
      centroids_fp      = cat(1,centroids_fp    ,[1 1]);
      centroids_fn      = cat(1,centroids_fn    ,[1 1]);
      switch pram.Nc
        case 1
          I_plot        = I_now(:,:,1);
        case 2
          I_plot(:,:,2) = 1   * I_now(:,:,1);
          I_plot(:,:,3) = 0.5 * I_now(:,:,2)/max(max(I_now(:,:,2)));
      end            
      imagesc(I_plot);axis image;hold on;colorbar
      plot(centroids_tp(:,1)    ,centroids_tp(:,2)    ,'+g','MarkerSize',30,'LineWidth',1);    
      plot(centroids_fn(:,1)    ,centroids_fn(:,2)    ,'+r','MarkerSize',30,'LineWidth',1);
      plot(centroids_fp(:,1)    ,centroids_fp(:,2)    ,'+w','MarkerSize',30,'LineWidth',1);    
      plot(centroids_fn_rpn(:,1),centroids_fn_rpn(:,2),'+m','MarkerSize',30,'LineWidth',1);    
      hold off      
      % truesize
      saveas(h,[resDir '/figs_rcn/' fileNameStem '_fig.jpeg']); 
      saveas(h,[resDir '/figs_rcn/' fileNameStem '_fig.fig']); 
      close(h)      
              
      %% plot/save rpn figures      
      h = figure('WindowState','maximized');
      L_plot = single(L_proposal>th_prop);
      L_plot = L_plot + 2*L_now;
      L_plot(1,1) = 3;% to avoid trying to overlay empty array
      imagesc(labeloverlay([I_plot/3],[L_plot]));axis image;
      saveas(h,[resDir '/figs_rpn/' fileNameStem '_figs.fig']);
      close(h)            
                  
      h = figure('WindowState','maximized');
      imagesc(L_proposal);axis image;hold on;colorbar
      plot(centroids_tp(:,1)    ,centroids_tp(:,2)    ,'+g','MarkerSize',30,'LineWidth',1);    
      plot(centroids_fn(:,1)    ,centroids_fn(:,2)    ,'+r','MarkerSize',30,'LineWidth',1);
      plot(centroids_fp(:,1)    ,centroids_fp(:,2)    ,'+w','MarkerSize',30,'LineWidth',1);    
      plot(centroids_fn_rpn(:,1),centroids_fn_rpn(:,2),'+m','MarkerSize',30,'LineWidth',1);    
      saveas(h,[resDir '/figs_rpn/' fileNameStem 'L_props_figs.fig']);
      close(h)
  end
  
  %% save results summary
  results_table         = table(Filename,...
                                Counts,Counts_gt,Area_tissue,...
                                Accuracy,Precision,Recall,...
                                TPs,FPs,FNs,FNs_rpn);
  writetable(results_table,[resDir 'run_' date '.xls']);
end







