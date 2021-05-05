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
%load ./__trainedNetworks/rpn_64_02-Mar-2021.mat  % legacy values
%load ./__trainedNetworks/rcn_64_02-Mar-2021.mat

load ./__trainedNetworks/rpn1_h2ax_tissue_h2ax_wadduwage2018automated_fig4_64_29-Mar-2021.mat % change these accordingly
load ./__trainedNetworks/rcn_h2ax_tissue_h2ax_wadduwage2018automated_fig4_64_29-Mar-2021.mat  % change these accordingly

use_pipeline(I.use,I.useNames,net_rpn,net_rcn,pram)

