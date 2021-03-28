% 20210328 by Dushan N Wadduwage
% This function matches GT to Proposals based on their centroids' seperation.

function [centr_proposals,...
          prop_tpIf1_fpIf0,...
          centroids_fn] = f_match_propBW_2_gtBW(L_prop,L_gt,pram)

  stats_proposals   = regionprops(L_prop,'Centroid');
  stats_gt          = regionprops(L_gt  ,'Centroid');

  centr_proposals   = cat(1,stats_proposals.Centroid);
  centr_gt          = cat(1,stats_gt.Centroid);

  if ~isempty(centr_gt) & ~isempty(centr_proposals)
    Dist_mat          = sqrt((centr_proposals(:,1) - centr_gt(:,1)').^2 + ...
                             (centr_proposals(:,2) - centr_gt(:,2)').^2);

    % find TPs, 
    [min_dist prop_ind] = min(Dist_mat,[],1);
    isNearApropObj      = min_dist<pram.gtDistTh;
    gt_ind_tp_withrep   = find(isNearApropObj==1);
    prop_ind_tp_withrep = prop_ind(gt_ind_tp_withrep);
    [prop_ind_tp, ...
     ia,...
     ic ]               = unique(prop_ind_tp_withrep); % [C,ia,ic] = unique(A) and C = A(ia) and A = C(ic)

    % find FNs
    gt_ind_fn           = setdiff(1:size(centr_gt,1),...
                                  gt_ind_tp_withrep(ia));  
    centroids_fn        = centr_gt(gt_ind_fn,:);

    % compile Y_gt for RCN-classigication
    prop_tpIf1_fpIf0              = zeros(size(centr_proposals,1),1);
    prop_tpIf1_fpIf0(prop_ind_tp) = 1;

    % temp_check_sum = [length(gt_ind_fn)+length(prop_ind_tp) size(centr_gt,1)];
  else
    prop_tpIf1_fpIf0    = zeros(size(Centroids,1),1);
    centroids_fn        = centr_gt(gt_ind_fn,:);
  end      




end