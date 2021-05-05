
function use_pipeline(Iuse,nameStem_use,net_rpn,net_rcn,pram)

  resDir        = sprintf('./results/%s/%s_%s/',...
                                     date,...             
                                        pram.experimentType,...
                                           pram.dataset)
  mkdir([resDir '/figs_rcn/']);
      
  Nx            = pram.Nx;
  th_prop       = pram.th_prop; % This is not good. We should try to make the propsal net work better
  for i=1:length(Iuse)
    i
    I_now             = Iuse{i};  
    fileNameStem      = nameStem_use{i};

    if pram.runTissueSeg == 1      
      [L_fg I_now Area_tissue_now L_now] = segmentTissueOtsu(I_now,[],Nx);% segments the tissue foreground, here L_now = [] 
    else
      L_fg            = ones(size(L_now))>0;
      L_fg            = padarray(L_fg,[Nx Nx]);
      I_now           = padarray(I_now,[Nx Nx]);
      Area_tissue_now = -1;
    end                    
    L_proposal        = apply_proposal_net(net_rpn,I_now,Nx);
    L_proposal(find(L_fg==0))=0;

    [I_proposals_now ...
     centroids        ]= genRegionProposals(L_proposal>th_prop,L_now,I_now,pram);

    if ~isempty(I_proposals_now)
      [YPred,scores]  = classify(net_rcn,I_proposals_now);
    else
      YPred           = [];
    end

    %% remove objects in the boundary (withon a 2*Nx range)
    limXs       = 1.5*Nx;
    limYs       = 1.5*Nx;
    limXe       = size(I_now,2) - 1.5*Nx;
    limYe       = size(I_now,1) - 1.5*Nx;

    if ~isempty(centroids)
      idx_valid         = centroids(:,1) >= limXs & centroids(:,2) >= limYs & ...
                          centroids(:,1) <= limXe & centroids(:,2) <= limYe;
      centroids         = centroids(idx_valid,:);
      YPred             = YPred(idx_valid);
    end

    %% analyse
    Count(i,1)          = sum(YPred=='1');          
    Filename{i,1}       = fileNameStem;    
    Area_tissue(i,1)    = Area_tissue_now; 

    centroids_positives = centroids(find(YPred=='1'),:);

    h = imagesc(I_now,[0 2.5]);hold on
    plot(centroids_positives(:,1),centroids_positives(:,2),'+g','MarkerSize',10,'LineWidth',1);
    hold off
    truesize
    saveas(h,[resDir 'figs_rcn/' fileNameStem '_fig.jpeg']);
  end  
  results_table = table(Filename,Count,Area_tissue);
  writetable(results_table,[resDir 'run_' date '.xls']);  
end

