% hightest acc collection for FDA purpose
% by: LJW
% purpose: combine the highest accurancy timelag for all three methods(mTRF/ CCA/ CCA speaker-listener)
% ... for FDA purpose


%% load data
load('E:\DataProcessing\FDA_complex_feature\hightest_acc\raw\mTRF_sound_EEG_result+328.125ms 64Hz 2-8Hz no flip lambda16384.mat');
load('E:\DataProcessing\FDA_complex_feature\hightest_acc\raw\cca_S-L_EEG_result+343.75ms 0.5-40Hz +64Hz r rank1.mat');
load('E:\DataProcessing\FDA_complex_feature\hightest_acc\raw\cca_sound_EEG_result+390.625ms 64Hz 0.5-40Hz.mat');

%% attend matrix
load('E:\DataProcessing\ListenA_Or_Not.mat');

%% FDA
predict_label_matrix = zeros(12,15);
decoding_correct_or_not = zeros(12,15);% 1 ->correct;0->wrong
test_weights_total = zeros(12,15);
accuracy_total = cell(12,15);
prob_estimates_total = cell(12,15);

for listener = 1 : 12
    
    for story = 1 : 15
        train_data_CCA = ...
            [recon_AttendDecoder_audioA_cca_train{listener,story};...
            recon_AttendDecoder_audioB_cca_train{listener,story};...
            recon_UnattendDecoder_audioA_cca_train{listener,story};...
            recon_UnattendDecoder_audioB_cca_train{listener,story}];
        %
        % All
        %         train_data_CCA_S_L=...
        %             [recon_AttendDecoder_speakerA_cca_train{listener,story};...
        %             recon_AttendDecoder_speakerB_cca_train{listener,story};...
        %             recon_UnattendDecoder_speakerA_cca_train{listener,story};...
        %             recon_UnattendDecoder_speakerB_cca_train{listener,story}];
        
        % diff
        train_data_CCA_S_L=...
            [recon_AttendDecoder_speakerA_cca_train{listener,story}-recon_AttendDecoder_speakerB_cca_train{listener,story};...
            recon_UnattendDecoder_speakerA_cca_train{listener,story}-recon_UnattendDecoder_speakerB_cca_train{listener,story}];
        
        train_data_mTRF = ... % attend and unattend decoder
            [recon_AttendDecoder_audioA_corr_train{listener,story};...
            recon_AttendDecoder_audioB_corr_train{listener,story};...
            recon_UnattendDecoder_audioA_corr_train{listener,story};...
            recon_UnattendDecoder_audioB_corr_train{listener,story}];
        
        train_data = [train_data_CCA; train_data_CCA_S_L;train_data_mTRF];
        labels = train_data_labels{listener,story}; % 1 ->attend;0->unattend
        
        % test data
        test_data_CCA = ... % attend and unattend decoder
            [recon_AttendDecoder_audioA_cca(listener,story);...
            recon_AttendDecoder_audioB_cca(listener,story);...
            recon_UnattendDecoder_audioA_cca(listener,story);...
            recon_UnattendDecoder_audioB_cca(listener,story)];
        
        test_data_CCA_S_L = ...
            [recon_AttendDecoder_speakerA_cca(listener,story)-recon_AttendDecoder_speakerB_cca(listener,story);...
            recon_UnattendDecoder_speakerA_cca(listener,story)- recon_UnattendDecoder_speakerB_cca(listener,story)];
        
        
        test_data_mTRF = ... % attend and unattend decoder
            [recon_AttendDecoder_audioA_corr(listener,story);...
            recon_AttendDecoder_audioB_corr(listener,story);...
            recon_UnattendDecoder_audioA_corr(listener,story);...
            recon_UnattendDecoder_audioB_corr(listener,story)];
        
        test_data = [test_data_CCA;test_data_CCA_S_L;test_data_mTRF];
        
        real_label =ListenA_Or_Not(story,listener);
        
        disp(strcat('Finding best CV for listener ',num2str(listener),' story ',num2str(story),'...'));
        % find best cv
        bestcv = 0;
        for log2c = -1:3
            for log2g = -4:1
                cmd = ['-v 14 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
                %                         cv = svmtrain(heart_scale_label, heart_scale_inst, cmd);
                cv = svmtrain(labels',train_data', cmd);
                if (cv >= bestcv)
                    bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
                end
                fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
            end
        end
        
        % best cmd
        best_cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg),' -b 1'];
        %         % FDA train
        %         disp(strcat('Training listener ',num2str(listener),' story ',num2str(story),'...'));
        %         [weights,intercept] = FDA_TRAIN(train_data,labels);
        %         [test_label,test_weights] = FDA_TEST(test_data,weights,intercept);
        %
        %         disp(strcat('Predicting listener ',num2str(listener),' story ',num2str(story),'...'));
        %         predict_label_matrix(listener,story)=test_label;
        %         test_weights_total(listener,story) = test_weights;
        
        % SVM train
        disp(strcat('Training listener ',num2str(listener),' story ',num2str(story),'...'));
        %                 [weights,intercept] = FDA_TRAIN(train_data,labels);
        model = svmtrain(labels',train_data',best_cmd);
        
        disp(strcat('Predicting listener ',num2str(listener),' story ',num2str(story),'...'));
        %                 test_label = FDA_TEST(test_data,weights,intercept);
        [test_label, accuracy, prob_estimates] = svmpredict(real_label', test_data', model, '-b 1');
        
        predict_label_matrix(listener,story)=test_label;
        accuracy_total{listener,story} = accuracy;
        prob_estimates_total{listener,story} = prob_estimates;
        
        if test_label == real_label
            decoding_correct_or_not(listener,story) = 1;
        else
            decoding_correct_or_not(listener,story) = 0;
        end
    end
end

% plot
decoding_acc = mean(decoding_correct_or_not,2);
plot_name = strcat('Three method decoding result.jpg');
plot(decoding_acc*100);
hold on;
plot(repmat(mean(decoding_acc*100),[1 12]),'k--');
title(plot_name(1:end-4));
xlabel('Subject No.'); ylabel('Decoding Accuarcy %');ylim([0,100]);
legend('Individual acc','Mean acc')
saveas(gcf,plot_name);
close


save_name = strcat('Three_method_hightest_acc_decoding_result.mat');
save(save_name,'decoding_correct_or_not','predict_label_matrix', 'accuracy_total','prob_estimates_total');