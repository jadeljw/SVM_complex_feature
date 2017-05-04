%% FDA decoding acc result timelag plot

%% timelag

% timelag = -200:25:500;
Fs = 64;

timelag = (-250:1000/Fs:500)/(1000/Fs);
% timelag = (-1000:500/32:1000)/(1000/Fs);

decoding_acc = zeros(1,length(timelag));
Decoding_acc_ttest_result = zeros(1,length(timelag));



%% lambda
lambda = 2 ^ 14;
band_name = strcat(' 64Hz 2-8Hz lambda',num2str(lambda));
% band_name = ' 64Hz 0.5-40Hz no flip';
% band_name = ' 128Hz 2-8Hz';
% band_name = strcat(' 128Hz 2-8Hz M1M2 lambda',num2str(lambda));
% band_name = ' broadband 0.5-40Hz after zscore';
% band_name = ' 0.5Hz-40Hz 64Hz r rank 1-60';


%% mTRF plot
p =strcat( 'E:\DataProcessing\SVM_complex_feature\decoding_result\mTRF\all\',band_name(2:end));
% category = 'CCA_speaker_listener_EEG';

for  j = 1 : length(timelag)
    % load data
    %     datapath = strcat(p,'\',category,'\',band_name{bandName}(2:end));
    datapath = p;
    dataName = strcat('mTRF_decoding_result+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.mat');
    load(strcat(datapath,'\',dataName));
    
    % ttest
    Decoding_acc_ttest_result(j) = ttest(mean(decoding_correct_or_not,2),0.5);
    decoding_acc(j)= mean(mean(decoding_correct_or_not,2));
    
end

figure; plot((1000/Fs)*timelag,decoding_acc*100,'k');
hold on;plot((1000/Fs)*timelag(Decoding_acc_ttest_result>0),decoding_acc(Decoding_acc_ttest_result>0)*100,'r*');
xlabel('Times(ms)'); ylabel('Decoding accuracy(%)')
saveName3 = strcat('Decoding-Acc across all time-lags using mTRF method',band_name,'.jpg');
title(saveName3(1:end-4));
legend('mTRF feature','significant ¡Ù 50%');ylim([30,100]);
saveas(gcf,saveName3);
close

