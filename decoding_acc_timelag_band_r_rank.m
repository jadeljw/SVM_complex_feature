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
% band_name{bandName} = strcat(' 64Hz 2-8Hz lambda',num2str(lambda));
band_name = {' delta_hilbert';' theta_hilbert';' alpha_hilbert';' beta_hilbert'};
% band_name = {' 0.5-40Hz +64Hz'};
% band_name{bandName} = ' 128Hz 2-8Hz';
% band_name{bandName} = strcat(' 128Hz 2-8Hz M1M2 lambda',num2str(lambda));
% band_name{bandName} = ' broadband 0.5-40Hz after zscore';
% band_name{bandName} = ' 0.5Hz-40Hz 64Hz r rank 1-60';

for bandName = 1 : length(band_name)
    for r = 1 : 3
        datafileName = strcat(band_name{bandName}(2:end),'+r rank',num2str(r));
        dataSaveName = strcat(band_name{bandName}(2:end),'+r rank',num2str(r));
        %     %% CCA
        %     p =strcat( 'E:\DataProcessing\FDA_complex_feature\decoding_result\CCA\diff\',band_name{bandName}(2:end));
        %     % category = 'CCA_speaker_listener_EEG';
        %
        %     for  j = 1 : length(timelag)
        %         % load data
        %         %     datapath = strcat(p,'\',category,'\',band_name{bandName}(2:end));
        %         datapath = p;
        %         dataName = strcat('CCA_sound_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms',band_name{bandName},'.mat');
        %         load(strcat(datapath,'\',dataName));
        %
        %         % ttest
        %         Decoding_acc_ttest_result(j) = ttest(mean(decoding_correct_or_not,2),0.5);
        %         decoding_acc(j)= mean(mean(decoding_correct_or_not,2));
        %
        %     end
        %
        %     figure; plot((1000/Fs)*timelag,decoding_acc*100,'k');
        %     hold on;plot((1000/Fs)*timelag(Decoding_acc_ttest_result>0),decoding_acc(Decoding_acc_ttest_result>0)*100,'r*');
        %     xlabel('Times(ms)'); ylabel('Decoding accuracy(%)')
        %     saveName3 = strcat('Decoding-Acc across all time-lags using CCA sound EEG method diff',band_name{bandName},'.jpg');
        %     title(saveName3(1:end-4));
        %     legend('CCA sound envelope feature','significant ¡Ù 50%');ylim([30,100]);
        %     saveas(gcf,saveName3);
        %     close
        
        %% CCA speaker-listener plot
                p =strcat( 'E:\DataProcessing\SVM_complex_feature\decoding_result\CCA_speaker_listener\diff\',datafileName);
%         p =strcat( 'E:\DataProcessing\SVM_complex_feature\decoding_result\CCA_speaker_listener\all\',dataNameSave);
        %     p =strcat( 'E:\DataProcessing\FDA_complex_feature\decoding_result\CCA_speaker_listener\train_set\',band_name(2:end));
        %     p =strcat( 'E:\DataProcessing\FDA_complex_feature\decoding_result\mTRF_CCA_SL_sound_EEG\',band_name(2:end));
        %     p =strcat( 'E:\DataProcessing\FDA_complex_feature\decoding_result\CCA_SL_sound_EEG\',band_name(2:end));
        
        % category = 'CCA_speaker_listener_EEG';
        
        for  j = 1 : length(timelag)
            % load data
            %     datapath = strcat(p,'\',category,'\',band_name{bandName}(2:end));
            datapath = p;
            dataName = strcat('cca_S-L_EEG_decoding_result_diff+ ',num2str((1000/Fs)*timelag(j)),'ms+',dataSaveName,'.mat');
            %          dataName = strcat('cca_S-L_cca_sound_EEG_decoding_result+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.mat');
            
            %         dataName = strcat('cca_S-L_EEG_decoding_result_train_set+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.mat');
            
            %         dataName = strcat('Three_method_decoding_result+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.mat');
            load(strcat(datapath,'\',dataName));
            
            % ttest
            Decoding_acc_ttest_result(j) = ttest(mean(decoding_correct_or_not,2),0.5);
            decoding_acc(j)= mean(mean(decoding_correct_or_not,2));
            
        end
        
        figure; plot((1000/Fs)*timelag,decoding_acc*100,'k');
        hold on;plot((1000/Fs)*timelag(Decoding_acc_ttest_result>0),decoding_acc(Decoding_acc_ttest_result>0)*100,'r*');
        xlabel('Times(ms)'); ylabel('Decoding accuracy(%)')
        saveName3 = strcat('Decoding-Acc across all time-lags using CCA-SL method+',dataSaveName,'.jpg');
        title(saveName3(1:end-4));
        legend('feature:CCA speaker-listener','significant ¡Ù 50%');ylim([30,100]);
        saveas(gcf,saveName3);
        close
        
    end
    
end