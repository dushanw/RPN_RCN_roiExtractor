% 2021-03-30 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
% 2021-06-17 edited by Dushan N. Wadduwage

clear all;clc;
addpath('./_supportingFunctions/')
%mkdir(['./__trainedNetworks/' date '/'])

pram                    = pram_init();
pram.TrDataDir          = './_data/bacteria_qpm3/'  
pram.ValDataRatio       = 0.3;  

%% train network
of                      = cd(pram.TrDataDir);
[XTr, YTr, XVal, YVal]  = readData(pram);
cd(of)

[XTr, YTr            ]  = f_augmentDataSet(XTr , YTr ,0);
[          XVal, YVal]  = f_augmentDataSet(XVal, YVal,0);

lgraph_mcrcn            = gen_MCRCN(pram);

pram.maxEpochs          = pram.maxEpochs_rcn;
pram.initLearningRate   = 1;
pram.dropPeriod         = round(pram.maxEpochs/4);
options                 = set_training_options(pram,XVal,YVal);

%lgraph_mcrcn           =  layerGraph(net_rcn);
[net_rcn, tr_info]      = trainNetwork(XTr,YTr,lgraph_mcrcn,options);
save(['./__trainedNetworks/' date '/' 'rcn' sprintf('_%s_%s_%d_%s.mat',pram.experimentType,...
                                                            pram.dataset,...
                                                            pram.Nx,datetime)],'net_rcn','tr_info'); 

%% use trained RCN on validation data for temporary analysis
Bacteria_Names          = {'Acinetobacter_Old',...
                           'B_subtilis_Old',...
                           'E_coli_K12_Old',...
                           'E_coli_CCUG17620_New',...
                           'E_coli_NCTC13441_New',...
                           'K_pneumoniae_A2-23_New',...
                           'S_aureus_CCUG35600_New'}';
I_proposals_now         = XVal;
YGt                     = YVal';
[YPred,scores]          = classify(net_rcn,I_proposals_now);

for i = 1:length(Bacteria_Names)
  Tot(i)                = sum(YGt==Bacteria_Names{i});
  TP(i)                 = sum( (YPred==Bacteria_Names{i}) &  (YGt==Bacteria_Names{i}) );
end
Success_rate            = (TP./Tot)';

% with second guess
[temp YPred_2nd]        = sort(scores,2,'descend');
YPred_2nd               = YPred_2nd(:,2);
YPred_2nd               = categorical({Bacteria_Names{YPred_2nd}}');
for i = 1:length(Bacteria_Names)
  Tot(i)                = sum(YGt==Bacteria_Names{i});
  TP(i)                 = sum( (YPred==Bacteria_Names{i} | YPred_2nd==Bacteria_Names{i} ) &  (YGt==Bacteria_Names{i}) );
end
Success_rate_with2guess = (TP./Tot)';

% save results
resDir                  = sprintf('./results/%s/%s_%s_%d/',...
                                             date,...             
                                                pram.experimentType,...
                                                   pram.dataset,...
                                                      pram.Nx)
mkdir(resDir);
results_table           = table(Bacteria_Names,...
                                Success_rate,...
                                Success_rate_with2guess)
writetable(results_table,[resDir 'run_' sprintf('%s',datetime) '.xls']);

%% Occlusion Sensitivity Analysis
load('./__trainedNetworks/07-Apr-2021/rcn_bacteria_qpm_bacteria_qpm_32_07-Apr-2021 06_10_48.mat');

Bacteria_Names          = {'Acinetobacter Old',...
                           'B subtilis Old',...
                           'E coli K12 Old',...
                           'E coli CCUG17620 New',...
                           'E coli NCTC13441 New',...
                           'K pneumoniae A2-23 New',...
                           'S aureus CCUG35600 New'}';
bac_classes             = categorical(...
                          {'Acinetobacter_Old',...
                           'B_subtilis_Old',...
                           'E_coli_K12_Old',...
                           'E_coli_CCUG17620_New',...
                           'E_coli_NCTC13441_New',...
                           'K_pneumoniae_A2-23_New',...
                           'S_aureus_CCUG35600_New'}');
for k=1:length(bac_classes)
  inds = find(YVal==bac_classes(k));
  for i=1:10
    [k i]
    X{k}(:,:,1,i)         = XVal(:,:,:,inds(i));
    Y{k}(i)               = YVal(inds(i));
    scoreMap{k}(:,:,1,i)  = occlusionSensitivity(net_rcn,...
                                                    XVal(:,:,:,inds(i)),...
                                                    YVal(inds(i)));  
  end
end
  
res_dir = ['./results/' date '/']
mkdir(res_dir)
for k=1:length(bac_classes)
  k
  XX(:,:,1) = imtile(imresize(X{k},5,'nearest'),'GridSize',[5,2]);
  XX(:,:,2) = XX(:,:,1);
  XX(:,:,3) = XX(:,:,1);
  imshow(rescale(XX));
  hold on
  imagesc(imtile(imresize(scoreMap{k},5,'nearest'),'GridSize',[5,2]),...
          'AlphaData',0.3);
  colormap jet;colorbar
  title(Bacteria_Names{k})
  hold off   
  
  saveas(gca,[res_dir sprintf('%s.tif',Bacteria_Names{k})]);
  close all
end
  
%% use trained RCN on validation data for population (/species/strain) level analysis

%save dir
resDir                  = sprintf('./results/%s/%s_%s_%d/',...
                                             date,...             
                                                pram.experimentType,...
                                                   pram.dataset,...
                                                      pram.Nx)
mkdir(resDir);

% load('./__trainedNetworks/07-Apr-2021/rcn_bacteria_qpm_bacteria_qpm_32_07-Apr-2021 06:10:48.mat');% on ubantu
% pram                    = pram_init();
% 
% of                      = cd(pram.TrDataDir);
% [XTr, YTr, XVal, YVal]  = readData(pram);
% cd(of)
% I_proposals_now         = XVal;
% YGt                     = YVal';
% [YPred,scores]          = classify(net_rcn,I_proposals_now);
% save([resDir 'calssif_res.mat'],'Bacteria_Names','YGt','YPred','scores');
                         
load('./results/28-May-2021/calssif_res.mat','Bacteria_Names','YGt','YPred','scores');

Bacteria_Classes          = {'Acinetobacter_Old',...
                           'B_subtilis_Old',...
                           'E_coli_K12_Old',...
                           'E_coli_CCUG17620_New',...
                           'E_coli_NCTC13441_New',...
                           'K_pneumoniae_A2-23_New',...
                           'S_aureus_CCUG35600_New'}';

Bacteria_Names          = {'Acinetobacter Old',...
                           'B subtilis Old',...
                           'E coli K12 Old',...
                           'E coli CCUG17620 New',...
                           'E coli NCTC13441 New',...
                           'K pneumoniae A2-23 New',...
                           'S aureus CCUG35600 New'}';                         

% single backteria classification accuracy
for i = 1:length(Bacteria_Names)
  Tot(i)                = sum(YGt==Bacteria_Classes{i});
  TP(i)                 = sum( (YPred==Bacteria_Classes{i}) &  (YGt==Bacteria_Classes{i}) );
end
Success_rate            = (TP./Tot)';
% figure;

bar(Success_rate*100);hold on
xs=[0;8];
plot(xs,[1;1]*100/7,'--k', 'LineWidth',2);%line
%ylim([0 n_bac(j)*1.0])

ylabel(sprintf('Classification Accuracy [%%]'))
xticklabels(Bacteria_Names)
xtickangle(45)
set(gca,'fontsize',16);

exportgraphics(gcf,[resDir sprintf('fig_Classification_Accuracy.png')],'Resolution',330)    


                         
n_bac = 2.^[0:9];
for i = 1:length(Bacteria_Classes)
  YPred_species_now     = YPred(YGt==Bacteria_Classes{i});
  N_bac                 = length(YPred_species_now);
  i
  for j = 1:length(n_bac)
    for k=1:100
      N_hist(i,j,k,:) = histcounts(YPred_species_now(randi(N_bac,[1, n_bac(j)])));
    end
  end
end
N_hist_avg = mean(N_hist,3);
N_hist_std = std (N_hist,[],3);
N_hist_se  = N_hist_std/sqrt(size(N_hist,3));
N_hist_min = min(N_hist,[],3);
N_hist_max = max(N_hist,[],3);

  %% population classifications at n_bac levels
n_bac         = 2.^[0:9]; 
n_repeats     = 1000; 
Bac_class_pop = zeros(length(Bacteria_Classes),length(n_bac),n_repeats,length(Bacteria_Classes));
for i = 1:length(Bacteria_Classes)
  YPred_prob_now      = scores(YGt==Bacteria_Classes{i},:);
  N_bac               = size(YPred_prob_now,1);
  i
  for j = 1:length(n_bac)
    for k=1:n_repeats
      [temp ind_mx] = max(sum(YPred_prob_now(randi(N_bac,[1, n_bac(j)]),:),1));
      Bac_class_pop(i,j,k,ind_mx) = Bac_class_pop(i,j,k,ind_mx)+1;
    end    
  end
end
Bac_class_pop_sum     = sum(Bac_class_pop,3);
Bac_class_pop_prcnt   = 100*sum(Bac_class_pop,3)/n_repeats;

for i = 1:length(Bacteria_Classes) % percentage plot
  i
  for j = 1:length(n_bac)
    % figure;
    
    bar(squeeze(Bac_class_pop_prcnt(i,j,:,:)));
    ylim([0 100])

    title(sprintf('%s (N=%d)',Bacteria_Names{i},n_bac(j)))
    ylabel(sprintf('%% of Predicted Calsses [%%]'))
    xticklabels(Bacteria_Names)
    xtickangle(45)
    set(gca,'fontsize',16);

    exportgraphics(gcf,[resDir sprintf('fig_Bac_class_pop_prcnt_%s_n-%d.png',Bacteria_Classes{i},n_bac(j))],'Resolution',330)    
  end
end

for i = 1:length(Bacteria_Classes) % correct-class-percentage vs. N plot
  i
  semilogx(n_bac,squeeze(Bac_class_pop_prcnt(i,:,:,i)),'-','MarkerSize',16,'LineWidth',2)
  hold on
  below100 = Bac_class_pop_prcnt(i,:,:,i) <  100;
  at100    = Bac_class_pop_prcnt(i,:,:,i) == 100;
  semilogx(n_bac(below100),squeeze(Bac_class_pop_prcnt(i,below100,:,i)),'Xr','MarkerSize',24,'LineWidth',2)
  semilogx(n_bac(at100   ),squeeze(Bac_class_pop_prcnt(i,at100   ,:,i)),'^k','MarkerSize',24,'LineWidth',2)
  hold off
  
  %     bar(squeeze(Bac_class_pop_prcnt(i,j,:,:)));
  ylim([0 110])
  title(sprintf('%s (N=%d)',Bacteria_Names{i},n_bac(j)))
  ylabel(sprintf('%% of Predicted Calsses [%%]'))  
  set(gca,'fontsize',24);

  exportgraphics(gcf,[resDir sprintf('fig_Bac_correct-class-vs-N_%s.png',Bacteria_Classes{i})],'Resolution',330)    
end

for i = 1:length(Bacteria_Classes) % min_bacN_for100pcnt plot
  i
  min_bacN_for100pcnt(i) = n_bac(min(find(squeeze(Bac_class_pop_prcnt(i,:,:,i))==100)));
end
bar(min_bacN_for100pcnt);hold on
ylabel(sprintf('Min ''N'' for 100%% Accuracy'))
xticklabels(Bacteria_Names)
xtickangle(45)
set(gca,'fontsize',16);
exportgraphics(gcf,[resDir sprintf('fig_min-N-for-100pcnt-Accuracy.png')],'Resolution',330)    

for i = 1:length(Bacteria_Classes) % sum plot
  i
  for j = 1:length(n_bac)
    % figure;
    
    bar(squeeze(Bac_class_pop_sum(i,j,:,:)));
    %ylim([0 n_bac(j)*1.0])

    title(sprintf('%s (N=%d)',Bacteria_Names{i},n_bac(j)))
    ylabel(sprintf('Average counts [AU]'))
    xticklabels(Bacteria_Names)
    xtickangle(45)
    set(gca,'fontsize',16);

    exportgraphics(gcf,[resDir sprintf('fig_Bac_class_pop_sum_%s_n-%d.png',Bacteria_Classes{i},n_bac(j))],'Resolution',330)    
  end
end

  %% average N_hist values for all population classifications
for i = 1:length(Bacteria_Classes)
  i
  for j = 1:length(n_bac)
    % figure;
    bar(squeeze(N_hist_avg(i,j,:,:)));
    ylim([0 n_bac(j)*1.0])
    hold on
    er = errorbar(1:size(N_hist_se,4),...
                  squeeze(N_hist_avg(i,j,:,:)),...
                  squeeze(N_hist_se(i,j,:,:)));     % se-error-bars (stadard error)
    er.Color = [0 0 0];                            
    er.LineWidth = 2;
    er.MarkerSize = 5;
    er.LineStyle = 'none';   
    hold off
    
    title(sprintf('%s (N=%d)',Bacteria_Names{i},n_bac(j)))
    ylabel(sprintf('Average counts [AU]'))
    xticklabels(Bacteria_Names)
    xtickangle(45)
    set(gca,'fontsize',16);

    exportgraphics(gcf,[resDir sprintf('fig_classHist_%s_n-%d.png',Bacteria_Classes{i},n_bac(j))],'Resolution',330)    
  end
end
      
%% single-blind colony level classification test 2021-06-01
load('./__trainedNetworks/07-Apr-2021/rcn_bacteria_qpm_bacteria_qpm_32_07-Apr-2021 06_10_48.mat');

pram.UseDataDir = './_data/bacteria_qpm2/';

of              = cd(pram.UseDataDir);
XTest           = readData(pram);
cd(of)

testInds        = randi(size(XTest.BacUnk,4),[1 100]);
[YPred,scores]  = classify(net_rcn,XTest.BacUnk(:,:,:,testInds));
[N,edges]       = histcounts(YPred);
N
subplot(1,2,1);histogram(YPred)

testInds        = randi(size(XTest.BacNew,4),[1 100]);
[YPred,scores]  = classify(net_rcn,XTest.BacNew(:,:,:,testInds));
[N,edges]       = histcounts(YPred);
subplot(1,2,2);histogram(YPred)
N


                         