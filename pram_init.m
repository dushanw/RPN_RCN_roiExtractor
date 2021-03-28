% 20200901 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
% parameter initialization

% datapaths
function pram = pram_init()
  pram.experimentType     = 'h2ax_tissue';   % {'nuc_tissue','h2ax_tissue','h2ax_cells'}
  pram.dataset            = 'h2ax_wadduwage2018automated_fig4';
                                            % {'nuc_tissue',
                                            %  'h2ax_tissue',
                                            %  'h2ax_cells',
                                            %  'h2ax_wadduwage2018automated_fig4',
                                            %  'h2ax_wadduwage2018automated_fig5'}        
  pram.TrDataDir          = ['./_data/' pram.dataset '/'];
  pram.UseDataDir         = ['./_data/' pram.dataset '/'];
  
  % experiment type and dataset dependent parameters
  switch pram.experimentType
    case 'nuc_tissue'      
      pram.runTissueSeg   = 0;              % tissue segmentation
      pram.miniBatchSize  = 256;
      pram.Nx             = 64;
      pram.Nc             = 1;
      pram.maxEpochs_rpn  = 20;
      pram.maxEpochs_rcn  = 10; 
      pram.th_prop        = 0.2;
      pram.gtDistTh       = 10;             % distant threshold for postive labeling using distant between the proposal 
                                            % centroids vs gt centroids
    case 'h2ax_tissue'
      switch pram.dataset
        case 'h2ax_tissue'                  % only 2020 h2ax_tissue has better sbr on tissue
          pram.runTissueSeg = 1;          
      otherwise
        pram.runTissueSeg   = 0;
      end      
      pram.imreasizeFactor= 1;              % 0.5 with Nx=64 tried (03-28-2021). See if 1 can beat it
      pram.miniBatchSize  = 256;
      pram.Nx             = 64;             % ?? 64 tried,128tried, 64 with 0.5 rsf
      pram.Nc             = 1;
      pram.maxEpochs_rpn  = 10;             % 
      pram.maxEpochs_rcn  = 8;              % ???
      pram.th_prop        = 0.9;            % ??
      pram.gtDistTh       = 10;             % ??? distant threshold for postive labeling using distant between the proposal 
                                            % centroids vs gt centroids
    case 'h2ax_cells'      
      pram.runTissueSeg   = 0;
      pram.miniBatchSize  = 256;
      pram.Nx             = 32;
      pram.Nc             = 2;
      pram.maxEpochs_rpn  = 30;             % ??
      pram.maxEpochs_rcn  = 10;             % ???
      pram.th_prop        = 0.2;            % ???  
      pram.gtDistTh       = 5;              % distant threshold for postive labeling using distant between the proposal 
                                            % centroids vs gt centroids
  end
  pram.maxEpochs          = pram.maxEpochs_rpn;
  
  % network paramters
  pram.ValDataRatio       = 0.05;           % ratio of training data used for validation
  pram.TestDataRatio      = 0.35;
  
  % training parameters 
  % pram.miniBatchSize      = 256;
  pram.initLearningRate   = 1;
  pram.learningRateFactor = .1;
  pram.dropPeriod         = round(pram.maxEpochs/4);
  pram.l2reg              = 0.0001;
  pram.excEnv             = 'multi-gpu';    % {'gpu','multi-gpu','cpu'}
end