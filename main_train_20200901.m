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

% addpath('./_data/h2ax_tissue/')     % copy original training data to this folder

clear all;clc;

addpath('./_supportingFunctions/')
mkdir('./__trainedNetworks/')

pram                    = pram_init(); % set paramters here
%pram.Nx                = 16;          % 16 is too small even for the h2ax-cell foci 
pram.Nx                 = 32;          % 32 works well for h2ax-cell foci at RPN stage 

%% train RPN
of                      = cd(pram.TrDataDir); 
[I L]                   = readData(pram); cd(of)    % I.tr, I.test, L.tr, L.test
% imagesc(imtile(I.tr{randi(length(I.tr))}));axis image;colorbar

[XTr, YTr, XVal, YVal]  = gen_tr_data_RPN(I.tr,L.tr,pram);
% imagesc(imtile(XVal(:,:,:,randi(size(XVal,4),1,100))));axis image;colorbar

lgraph_rpn              = gen_RPN(pram);

% pram.maxEpochs          = 60;
pram.maxEpochs          = 30;                       % 30 seeems enough for Nx32 with h2ax-cells
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

net_rpn                 = trainNetwork(XTr,YTr,lgraph_rpn,options);
save(['./__trainedNetworks/rpn' sprintf('_%d_%s.mat',pram.Nx,date)],'net_rpn');

%% train RCN
[XTr, YTr, XVal, YVal]  = gen_tr_data_RCN(I.tr,L.tr,net_rpn,pram);
lgraph_rcn              = gen_RCN(net_rpn);

% pram.maxEpochs        = 80;% for sr paper fig 4 data 100 epochs work well, more than than over fits
pram.maxEpochs          = 40;% for h2ax-cells data 40 epochs work well, more than than over fits
pram.initLearningRate   = 0.1;
pram.dropPeriod         = round(pram.maxEpochs/2);
options                 = set_training_options(pram,XVal,YVal);

net_rcn                 = trainNetwork(XTr,YTr,lgraph_rcn,options);
save(['./__trainedNetworks/rcn' sprintf('_%d_%s.mat',pram.Nx,date)],'net_rcn');

%% validate networks
validate(I.test,L.test,I.test_nameStem,net_rpn,net_rcn,pram)



