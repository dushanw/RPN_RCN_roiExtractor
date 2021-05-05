% 20210303 by Dushan N. Wadduwage (wadduwage@fas.harvard.edu)
% This is an example of how to use a trained pipeline

clear all;close all;clc
addpath('./_supportingFunctions/')
pram = pram_init(); % set paramters here

%% train RPN
of  = cd(pram.UseDataDir);
I   = readData(pram);     % I.use
cd(of)


%% use network
load ./__trainedNetworks/rpn_64_02-Mar-2021.mat
load ./__trainedNetworks/rcn_64_02-Mar-2021.mat
use_pipeline(net_rpn,net_rcn,pram)

