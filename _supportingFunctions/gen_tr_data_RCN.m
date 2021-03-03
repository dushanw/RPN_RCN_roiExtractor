
function [XTr, YTr, XVal, YVal] = gen_tr_data_RCN(net_RPN,pram)

  Nx            = pram.Nx;

  In_imds_dir   = fullfile(pram.TrDataDir,'Imds');
  Out_imds_dir  = fullfile(pram.TrDataDir,'Pxds');

  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  L_imds        = imageDatastore(Out_imds_dir);

  I_all         = In_imds.readall;
  L_all         = L_imds.readall;

  th_prop       = pram.th_prop;
  th_gt         = pram.th_gt;% jenny's annotation are dark dots on bright bg on 16bit image
  I_proposals   = [];
  Y_gt          = [];

  for i=1:length(I_all)
      i
      [L_fg, I_now, A, L_now] = segmentTissueOtsu(I_all{i},L_all{i},Nx);

      L_proposal                = apply_proposal_net(net_RPN,I_now,Nx);
      L_proposal(find(L_fg==0)) = 0;
      [I_proposals_now, Centroids{i}, Y_gt_now] = genRegionProposals(L_proposal>th_prop,L_now<th_gt,I_now,Nx);

      I_proposals               = cat(4,I_proposals,I_proposals_now);
      Y_gt                      = cat(1,Y_gt,Y_gt_now); 
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