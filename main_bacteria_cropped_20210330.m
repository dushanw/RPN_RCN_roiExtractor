% 2020-03-30 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)

clear all;clc;
addpath('./_supportingFunctions/')
mkdir(['./__trainedNetworks/' date '/'])

pram                    = pram_init();

of                      = cd(pram.TrDataDir);
[XTr, YTr, XVal, YVal]  = readData(pram);
cd(of)
  
lgraph_mcrcn            = gen_MCRCN(pram);

pram.maxEpochs          = pram.maxEpochs_rcn;
pram.initLearningRate   = 0.1;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

[net_rcn, tr_info]      = trainNetwork(XTr,YTr,lgraph_mcrcn,options);

