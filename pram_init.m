% 20200901 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
% parameter initialization

% datapaths
function pram = pram_init()
  pram.experimentType     = 'bacteria_qpm';% {'nuc_tissue','h2ax_tissue','h2ax_cells','bacteria_qpm'}
  pram.dataset            = 'bacteria_qpm';
                                            % {'nuc_tissue',
                                            %  'h2ax_tissue',
                                            %  'h2ax_cells',
                                            %  'h2ax_wadduwage2018automated_fig4',
                                            %  'h2ax_wadduwage2018automated_fig5',
                                            %  'bacteria_qpm'}
  pram.TrDataDir          = ['./_data/' pram.dataset '/'];
  pram.UseDataDir         = ['./_data/' pram.dataset '_use/'];
  
  % experiment type and dataset dependent parameters
  switch pram.experimentType
    case 'nuc_tissue'      
      pram.runTissueSeg   = 0;              % tissue segmentation
      pram.imreasizeFactor= 1;
      pram.miniBatchSize  = 256;
      pram.Nx             = 64;
      pram.Nc             = 1;
      pram.maxEpochs_rpn0 = 5;              % 20 takes 14hrs with aug0. switching to 5
      pram.maxEpochs_rpn1 = 5;              % same as above. switching to 5.
      pram.maxEpochs_rcn  = 10; 
      pram.th_prop        = 0.5;            % if was 0.2; but trying 0.5 to stadarize. 
      pram.gtDistTh       = 10;             % distant threshold for postive labeling using distant between the proposal centroids vs gt centroids
    case 'h2ax_tissue'
      switch pram.dataset
        case 'h2ax_tissue'                  % only 2020 h2ax_tissue has better sbr on tissue
          pram.runTissueSeg = 1;          
      otherwise
        pram.runTissueSeg   = 0;
      end      
      pram.imreasizeFactor= 0.5;            % 0.5 with Nx=64 tried (03-28-2021). See if 1 can beat. it-could not; still missing diffused foci(29-03-2021); stick to 0.5(29-03-2021 results)
      pram.miniBatchSize  = 256;
      pram.Nx             = 64;             % 64 tried-missing diffused foci every try, 
                                            % 128tried-too slow, 
                                            % 64 with 0.5 rsf-works-ok
      pram.Nc             = 1;
      pram.maxEpochs_rpn0 = 12;             % 
      pram.maxEpochs_rpn1 = 12;             % 
      pram.maxEpochs_rcn  = 24;             % 
      pram.th_prop        = 0.5;            % 0.9 works well, but start with 0.5 to standarise before th selection; 0.5 works fine with autoselect
      pram.gtDistTh       = 10;             % distant threshold for postive labeling using distant between the proposal centroids vs gt centroids
    case 'h2ax_cells'      
      pram.runTissueSeg   = 0;
      pram.imreasizeFactor= 1;
      pram.miniBatchSize  = 512;
      pram.Nx             = 32;
      pram.Nc             = 2;
      pram.Nclasses       = 2;              % classes here are fg,bg
      pram.maxEpochs_rpn0 = 12;             % it was 30 before; now trying 12 with augmentation-12 seems to be ok
      pram.maxEpochs_rpn1 = 12;             % 
      pram.maxEpochs_rcn  = 12;             % ???
      pram.th_prop        = 0.5;            % ??? it was 0.2; but trying 0.5 to standarize 
      pram.gtDistTh       = 5;              % distant threshold for postive labeling using distant between the proposal centroids vs gt centroids
    case 'bacteria_qpm'      
      pram.runTissueSeg   = 0;
      pram.imreasizeFactor= 0.64;           % ???
      pram.miniBatchSize  = 256;            % ???
      pram.Nx             = 32;             % ???
      pram.Nc             = 1;
      pram.Nclasses       = 7;              % classes here are backteria classes see readdata in bacteeria dataset
      pram.maxEpochs_rpn0 = 12;             % just for the rest of the code (rpn is not used here)
      pram.maxEpochs_rcn  = 24;             % 
  end
  pram.maxEpochs          = pram.maxEpochs_rpn0;
  
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