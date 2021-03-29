% 20210328 by Dushan N. Wadduwage
% A function to set the region selection threshold for RPN output map

function th_prop = f_setRegionPropTh(I_list,L_gt_list,net_rpn,pram,slectionsMethod)

  %% apply rpn network for all training images
  for i=1:length(I_list)  
    i
    L_gt_list{i}        = padarray(L_gt_list{i},[pram.Nx pram.Nx]);
    I_list{i}           = padarray(I_list{i},[pram.Nx pram.Nx]);
    L_propProb_list{i}  = apply_proposal_net(net_rpn,I_list{i},pram.Nx);
  end
  
  %% theresholds values to be selected from
  d_th    = 0.1;
  th_list = d_th:d_th:1-d_th;  
  
  %% calculate FN, TP, and FP rates for each threshold value
  N_FN = zeros(length(th_list),1);
  N_TP = zeros(length(th_list),1);
  N_FP = zeros(length(th_list),1);  
  for k = 1:length(th_list)
    k
    for i=1:length(I_list)
      L_prop            = L_propProb_list{i}>=th_list(k);
      L_gt              = L_gt_list{i};

      [centr_proposals,...
          prop_tpIf1_fpIf0,...
          centroids_fn] = f_match_propBW_2_gtBW(L_prop,L_gt,pram);
      
      N_FN(k)               = N_FN(k) + size(centroids_fn,1);
      N_TP(k)               = N_TP(k) + sum(prop_tpIf1_fpIf0 == 1);
      N_FP(k)               = N_FP(k) + sum(prop_tpIf1_fpIf0 == 0);      
    end
  end
  [N_FN N_TP N_FP N_FN+N_TP]      
  Accuracy    = N_TP./(N_TP+N_FN+N_FP)        
  Recall      = N_TP./(N_TP+N_FN)
  Precision   = N_TP./(N_TP+N_FP)
  
  %% thereshold value selection
  switch slectionsMethod
    case 'accuracy'
      inds_max    = find(Accuracy == max(Accuracy));
      th_prop     = th_list(inds_max(end));
    case 'recall'
      inds_max    = find(Recall == max(Recall));
      th_prop     = th_list(inds_max(end));
%       inds_minNFN = find(N_FN == min(N_FN));
%       [temp ind]  = min(N_FP(inds_minNFN));
%       th_prop     = th_list(inds_minNFN(ind));
  end
end





