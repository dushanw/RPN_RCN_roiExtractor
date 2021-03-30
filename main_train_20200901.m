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
mkdir(['./__trainedNetworks/' date '/'])
pram                    = pram_init(); % set paramters here

%% train RPN
of                      = cd(pram.TrDataDir);
[I L]                   = readData(pram);     % I.tr, I.test, L.tr, L.test
cd(of)
% imagesc(imtile(I.tr{randi(length(I.tr))}));axis image;colorbar

[XTr, YTr, XVal, YVal]  = gen_tr_data_RPN(I.tr,L.tr,pram);
[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr ,0);
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal,0);
% imagesc(imtile(XVal(:,:,:,randi(size(XVal,4),1,100))));axis image;colorbar

lgraph_rpn              = gen_RPN(pram);
pram.maxEpochs          = pram.maxEpochs_rpn0;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

[net_rpn, tr_info]      = trainNetwork(XTr,YTr,lgraph_rpn,options);% 30mins for h2ax-tissue-fig4
save(['./__trainedNetworks/' date '/' 'rpn0' sprintf('_%s_%s_%d_%s.mat',pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,date)],'net_rpn','tr_info');

%% retrain RPN for cell spliting % skip for h2ax-tissue
% pram.th_prop            = f_setRegionPropTh(I.tr,L.tr,net_rpn,pram,'accuracy');
[XTr, YTr, XVal, YVal]  = gen_tr_data_RPN_refine(I.tr,L.tr,net_rpn,pram);
[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr ,1);
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal,1);

pram.maxEpochs          = pram.maxEpochs_rpn;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

[net_rpn, tr_info]      = trainNetwork(XTr,YTr,layerGraph(net_rpn),options);
save(['./__trainedNetworks/rpn1' sprintf('_%s_%s_%d_%s.mat',pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,date)],'net_rpn','tr_info'); 

%% train RCN                    
pram.th_prop            = f_setRegionPropTh(I.tr,L.tr,net_rpn,pram,'recall');
[XTr, YTr, XVal, YVal]  = gen_tr_data_RCN(I.tr,L.tr,net_rpn,pram);
[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr ,0);
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal,0);

lgraph_rcn              = gen_RCN(net_rpn);
pram.maxEpochs          = pram.maxEpochs_rcn;
pram.initLearningRate   = 0.1;      % ??? still needed? 
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

tic
[net_rcn, tr_info]      = trainNetwork(XTr,YTr,lgraph_rcn,options);
toc
save(['./__trainedNetworks/' date '/' 'rcn' sprintf('_%s_%s_%d_%s.mat', pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,date)],'net_rcn','tr_info');

validate(I.test,L.test,I.testNames,net_rpn,net_rcn,pram)

% 2021-03-20 tested the h2ax-cell dataset for runtime errors. didn't test the accuray. 
% 2021-03-22 tested the h2ax-tissue dataset for runtime errors. didn't test the accuray. 
% 2021-03-23 tested the nuc-tissue dataset for runtime errors. didn't test the accuray. 
% 2021-03-26 trained and analysed the results for h2ax-tissue. pram.th_prop was = 0.2. The results were bad. Now trying 0.9 
%             => 0.9 worked well witl Nx=64. But thee scattered foci were not visible. so tryied Nx=128 to increse the receptive field
% 2021-03-27  => Nx=128 did not improve the results. it was time consuming to train. so the training might have been off. But switching back to Nx=64. But going to resize the image by 0.5 to increse the receptive field
%           

%% validate networks 2021-03-20 still not cleaned up
% load('./__trainedNetworks/rpn_32_12-Mar-2021_twoCh.mat')
% load('./__trainedNetworks/rcn_32_12-Mar-2021_twoCh.mat')

validate(I.test,L.test,I.testNames,net_rpn,net_rcn,pram)


