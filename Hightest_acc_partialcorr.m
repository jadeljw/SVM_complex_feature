% hightest acc collection for FDA purpose
% by: LJW
% purpose: combine the highest accurancy timelag for all three methods(mTRF/ CCA/ CCA speaker-listener)
% ... for FDA purpose


%% load data
% CCA
load('E:\DataProcessing\SVM_complex_feature\highest_acc\svm\decoding\CCA_sound_EEG_result+390.625ms 64Hz 0.5-40Hz.mat');
CCA_sound_EEG_prob_estimates = cell2mat(prob_estimates_total);
CCA_sound_EEG_prob_estimates = CCA_sound_EEG_prob_estimates(:,1:2:end);
CCA_sound_EEG_prob_estimates = CCA_sound_EEG_prob_estimates(:);

% mTRF
load('E:\DataProcessing\SVM_complex_feature\highest_acc\svm\decoding\mTRF_decoding_result+328.125ms 64Hz 2-8Hz no flip lambda16384.mat');
mTRF_prob_estimates = cell2mat(prob_estimates_total);
mTRF_prob_estimates = mTRF_prob_estimates(:,1:2:end);
mTRF_prob_estimates = mTRF_prob_estimates(:);

load('E:\DataProcessing\SVM_complex_feature\highest_acc\svm\decoding\cca_S-L_EEG_decoding_result_diff+343.75ms+ 0.5-40Hz +64Hz r rank1.mat');
CCA_S_L_prob_estimates = cell2mat(prob_estimates_total);
CCA_S_L_prob_estimates = CCA_S_L_prob_estimates(:,1:2:end);
CCA_S_L_prob_estimates = CCA_S_L_prob_estimates(:);

%% attend matrix
load('E:\DataProcessing\ListenA_Or_Not.mat');

ListenA_Or_Not = ListenA_Or_Not';
ListenA_Or_Not = ListenA_Or_Not(:);

%% partial correlation