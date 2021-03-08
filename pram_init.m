% 20200901 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
% parameter initialization

% datapaths
function pram = pram_init()
  pram.experimentType     = 'h2ax_cells';  
  pram.TrDataDir          = './_data/h2ax_cells/';
  pram.UseDataDir         = './_data/h2ax_cells/';

  % tissue segmentation
  pram.runTissueSeg       = 0;
  % network paramters
  pram.Nx                 = 64;
  pram.ValDataRatio       = 0.05; % ratio of training data used for validation
  pram.TestDataRatio      = 0.35;

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
end