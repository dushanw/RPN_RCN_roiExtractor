% 20200901 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
% parameter initialization

% datapaths
pram.TrDataDir          = './_data/h2ax_tissue/';

% network paramters
pram.Nx                 = 64;
pram.ValDataRatio       = 0.05; % ratio of training data used for validation

% hyper-parameter of the rule-based algorithm
pram.th_prop            = 0.99;
pram.th_gt              = 20000;% jenny's annotation are dark dots on bright bg on 16bit image

% training parameters 
pram.maxEpochs          = 20;
pram.miniBatchSize      = 256;
pram.initLearningRate   = 1;
pram.learningRateFactor = .1;
pram.dropPeriod         = round(pram.maxEpochs/4);
pram.l2reg              = 0.0001;
pram.excEnv             = 'multi-gpu';   % 'gpu', 'multi-gpu'
