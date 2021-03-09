
function [XTr, YTr, XVal, YVal] = gen_tr_data_RCN(I_all,L_all,net_RPN,pram)

  Nx            = pram.Nx;

  th_prop       = pram.th_prop;

  I_proposals   = [];
  Y_gt          = [];

  for i=1:length(I_all)
      i
            
      if pram.runTissueSeg == 1      
        [L_fg I_now Area_tissue_now L_now] = segmentTissueOtsu(I_all{i},L_all{i},Nx);% segments the tissue foreground 
      else        
        I_now           = padarray(I_all{i},[Nx Nx]);
        L_fg            = ones(size(L_all{i}))>0;
        L_fg            = padarray(L_fg,[Nx Nx]);
        L_now           = padarray(L_all{i},[Nx Nx]);        
        Area_tissue_now = -1;
      end
      
      L_proposal                = apply_proposal_net(net_RPN,I_now,Nx);
      L_proposal(find(L_fg==0)) = 0;
      % L         = imextendedmax(L_proposal,0.01); % anoter way is to use the extended maxima transform 
      [I_proposals_now, Centroids{i}, Y_gt_now] = genRegionProposals(L_proposal>th_prop,L_now,I_now,Nx);

      if ~isempty(I_proposals_now)
        I_proposals               = cat(4,I_proposals,I_proposals_now);
        Y_gt                      = cat(1,Y_gt,Y_gt_now); 
      end
  end
  N_trTot   = length(Y_gt);
  N_val     = round(N_trTot*pram.ValDataRatio);
      
  randInds  = randperm(N_trTot);
  XTr0      = I_proposals(:,:,1,randInds);
  YTr0      = categorical(Y_gt(randInds));

  XVal      = XTr0(:,:,:,1:N_val);
  YVal      = YTr0(1:N_val);
  XTr       = XTr0(:,:,:,N_val+1:end); 
  YTr       = YTr0(N_val+1:end); 
end