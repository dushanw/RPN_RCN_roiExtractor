% 20200901 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
%
% Foci counter with Region Proposal(RPN) + Region Classification(RCN) 
% NetworkArchitectures: 
%     RPN = SharedLahyers + 2x(Conv)+ SofMax + Classification
%     RCN = SharedLahyers + FC      + SofMax + Classification
% TrainingMode: 
%     1. Train RPN 
%     2. Run RPN on original images to extract proposals
%     3. Make RCN from trained SharedLahyers
%     4. Train RCN
% RunMode: 
%     1. Run RPN 
%     2. Region Proposal Extraction 
%     3. Run RCN

addpath('./_data0/') % copy original training data to this folder
addpath('./_supportingFunctions/')

pram_init; % set paramters here

%% train RPN
lgraph_rpn              = gen_RPN(pram);
[XTr, YTr, XVal, YVal]  = gen_tr_data_RPN(pram);

pram.maxEpochs          = 12;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

net_rpn                 = trainNetwork(XTr,YTr,lgraph_rpn,options);
save(['./__trainedNetworks/rpn' sprintf('_%d_%s.mat',pram.Nx,date)],'net_rpn');

%% train RCN
[XTr, YTr, XVal, YVal]  = gen_tr_data_RCN(net_rpn,pram);
lgraph_rcn              = gen_RCN(net_rpn);

pram.maxEpochs          = 400;
pram.initLearningRate   = 0.1;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

net_rcn                 = trainNetwork(XTr,YTr,lgraph_rcn,options);
save(['./__trainedNetworks/rcn' sprintf('_%d_%s.mat',pram.Nx,date)],'net_rcn');

%% validate networks
validate(net_rpn,net_rcn,pram)



