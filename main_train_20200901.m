% 20200901 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
%% readme                       
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

%% 
clear all;clc;
addpath('./_supportingFunctions/')
mkdir('./__trainedNetworks/')
pram                    = pram_init(); % set paramters here

%% train RPN                    
of                      = cd(pram.TrDataDir);
[I L]                   = readData(pram);     % I.tr, I.test, L.tr, L.test
cd(of)
% imagesc(imtile(I.tr{randi(length(I.tr))}));axis image;colorbar

[XTr, YTr, XVal, YVal]  = gen_tr_data_RPN(I.tr,L.tr,pram);
[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr );
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal);
% imagesc(imtile(XVal(:,:,:,randi(size(XVal,4),1,100))));axis image;colorbar

lgraph_rpn              = gen_RPN(pram);
pram.maxEpochs          = pram.maxEpochs_rpn;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

[net_rpn, tr_info]      = trainNetwork(XTr,YTr,lgraph_rpn,options);
save(['./__trainedNetworks/rpn0' sprintf('_%s_%s_%d_%s.mat',pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,date)],'net_rpn','tr_info');

%% retrain RPN for cell spliting
[XTr, YTr, XVal, YVal]  = gen_tr_data_RPN_refine(I.tr,L.tr,net_rpn,pram);
[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr );
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal);

pram.maxEpochs          = pram.maxEpochs_rpn;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

[net_rpn, tr_info]      = trainNetwork(XTr,YTr,lgraph_rpn,options);
save(['./__trainedNetworks/rpn1' sprintf('_%s_%s_%d_%s.mat',pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,date)],'net_rpn','tr_info');

%% train RCN                    
[XTr, YTr, XVal, YVal]  = gen_tr_data_RCN(I.tr,L.tr,net_rpn,pram);
[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr );
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal);

lgraph_rcn              = gen_RCN(net_rpn);
pram.maxEpochs          = pram.maxEpochs_rcn;
% pram.initLearningRate   = 0.1;      % ??? still needed? 
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

[net_rcn, tr_info]      = trainNetwork(XTr,YTr,lgraph_rcn,options);
save(['./__trainedNetworks/rcn' sprintf('_%s_%s_%d_%s.mat', pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,date)],'net_rcn','tr_info');



% 2021-03-20 tested the h2ax-cell dataset for runtime errors. didn't test the accuray. 
% 2021-03-22 tested the h2ax-tissue dataset for runtime errors. didn't test the accuray. 
% 2021-03-23 tested the nuc-tissue dataset for runtime errors. didn't test the accuray. 


%% validate networks 2021-03-20 still not cleaned up
% load('./__trainedNetworks/rpn_32_12-Mar-2021_twoCh.mat')
% load('./__trainedNetworks/rcn_32_12-Mar-2021_twoCh.mat')

validate(I.test,L.test,I.testNames,net_rpn,net_rcn,pram)





