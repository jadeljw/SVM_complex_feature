% FDA for CCA speaker-listener result
% 2017.1.9
% LJW : jx_ljw@163.com
% for speaker-listener experiment
% organize feature as r(attend_A)-r(unattend_A) r(attend_B)-r(unattend_B)

%% timelag
Fs = 64;
% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
timelag = (-250:1000/Fs:500)/(1000/Fs);
% timelag = 0 ;


%% path
path_name = 'E:\DataProcessing\FDA_complex_feature\CCA-speaker-listener';

%% attend matrix
load('E:\DataProcessing\ListenA_Or_Not.mat');

%% work path
p = pwd;

%% band name
% band_name = {' delta_hilbert';' theta_hilbert';' alpha_hilbert';' beta_hilbert';' 0.5-40Hz +64Hz'};
band_name = {' 0.5-40Hz +64Hz'};
for bandName = 1 : length(band_name)
    
    for r = 1 
        
        %% data name
        %         dataName = strcat(band_name{bandName}(2:end),'+r rank',num2str(r));
        dataName = strcat(band_name{bandName},' r rank',num2str(r));
        mkdir(dataName);
        cd(dataName);
        
        
        for j = 1 : length(timelag)
            
            data_name = strcat('cca_S-L_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms',dataName,'.mat');
%             load(strcat(path_name,'\',dataName,'\',data_name));
            load(strcat(path_name,'\',dataName(2:end),'\',data_name));
            predict_label_matrix = zeros(12,15);
            test_weights_total = zeros(12,15);
            decoding_correct_or_not = zeros(12,15);% 1 ->correct;0->wrong
            accuracy_total = cell(12,15);
            prob_estimates_total = cell(12,15);
            
            for listener = 1 : 12
                
                for story = 1 : 15
                    
                    %                     train_data = ...
                    %                         [recon_AttendDecoder_speakerA_cca_train{listener,story};
                    %                         recon_UnattendDecoder_speakerA_cca_train{listener,story};...
                    %                         recon_AttendDecoder_speakerB_cca_train{listener,story};...
                    %                         recon_UnattendDecoder_speakerB_cca_train{listener,story};];
                    train_data = ...
                        [recon_AttendDecoder_speakerA_cca_train{listener,story}-recon_UnattendDecoder_speakerA_cca_train{listener,story};...
                        recon_AttendDecoder_speakerB_cca_train{listener,story}-recon_UnattendDecoder_speakerB_cca_train{listener,story};];
                    
                    labels = train_data_labels{listener,story}; % 1 ->attend;0->unattend
                    
                    % test data
                    %                     test_data = ...
                    %                         [recon_AttendDecoder_speakerA_cca(listener,story);...
                    %                         recon_UnattendDecoder_speakerA_cca(listener,story);...
                    %                         recon_AttendDecoder_speakerB_cca(listener,story);...
                    %                         recon_UnattendDecoder_speakerB_cca(listener,story);];
                    
                    test_data = ...
                        [recon_AttendDecoder_speakerA_cca(listener,story)-recon_UnattendDecoder_speakerA_cca(listener,story);...
                        recon_AttendDecoder_speakerB_cca(listener,story)-recon_UnattendDecoder_speakerB_cca(listener,story);];
                    
                    real_label = ListenA_Or_Not(story,listener);
                    
                    
                    %                     % FDA train
                    %                     disp(strcat('Training listener ',num2str(listener),' story ',num2str(story),'...'));
                    %                     [weights,intercept] = FDA_TRAIN(train_data,labels);
                    %                     [test_label,test_weights] = FDA_TEST(test_data,weights,intercept);
                    %
                    %                     disp(strcat('Predicting listener ',num2str(listener),' story ',num2str(story),'...'));
                    %                     predict_label_matrix(listener,story)=test_label;
                    %                     test_weights_total(listener,story)= test_weights;
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
            plot_name = strcat('cca S-L EEG decoding result diff+',num2str((1000/Fs)*timelag(j)),'ms+',dataName,'.jpg');
            plot(decoding_acc*100);
            hold on;
            plot(repmat(mean(decoding_acc*100),[1 12]),'k--');
            title(plot_name(1:end-4));
            xlabel('Subject No.'); ylabel('Decoding Accuarcy %');ylim([0,100]);
            legend('Individual acc','Mean acc')
            saveas(gcf,plot_name);
            close
            
            
            save_name = strcat('cca_S-L_EEG_decoding_result_diff+',num2str((1000/Fs)*timelag(j)),'ms+',dataName,'.mat');
            
            save(save_name,'decoding_correct_or_not','predict_label_matrix', 'accuracy_total','prob_estimates_total');
            
        end
        
        cd(p);
    end
end