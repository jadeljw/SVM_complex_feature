% SVM for CCA sound-EEG result
% 2017.5.2
% LJW : jx_ljw@163.com
% for speaker-listener experiment

%% timelag
Fs = 64;
% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
timelag = (-250:1000/Fs:500);
% timelag = 0 ;

%% band name
% band_name = {' delta_hilbert';' theta_hilbert';' alpha_hilbert';' beta_hilbert'};
band_name = {' 64Hz 0.5-40Hz'};
%% workpath
p = pwd;

for bandName = 1 : length(band_name)
    
    mkdir(band_name{bandName}(2:end));
    cd(band_name{bandName}(2:end));
    
    %% path
    path_name = 'E:\DataProcessing\FDA_complex_feature\CCA';
    
    %% attend matrix
    load('E:\DataProcessing\ListenA_Or_Not.mat');
    
    %% load data
    
    
    for j = 1 : length(timelag)
        %         band_name{bandName} = ' 64Hz 0.5-40Hz no flip';
        
        data_name = strcat('cca_sound_EEG_result+',num2str(timelag(j)),'ms',band_name{bandName},'.mat');
        load(strcat(path_name,'\',band_name{bandName}(2:end),'\',data_name));
        predict_label_matrix = zeros(12,15);
        decoding_correct_or_not = zeros(12,15);% 1 ->correct;0->wrong
        accuracy_total = cell(12,15);
        prob_estimates_total = cell(12,15);
        
        
        for listener = 1 : 12
            
            for story = 1 : 15
                
                train_data = ... % attend and unattend decoder all
                    [recon_AttendDecoder_audioA_cca_train{listener,story};...
                    recon_AttendDecoder_audioB_cca_train{listener,story};...
                    recon_UnattendDecoder_audioA_cca_train{listener,story};...
                    recon_UnattendDecoder_audioB_cca_train{listener,story}];
                
                %                 train_data = ... % attend and unattend decoder diff
                %                     [recon_AttendDecoder_audioA_cca_train{listener,story} - recon_AttendDecoder_audioB_cca_train{listener,story};...
                %                     recon_UnattendDecoder_audioA_cca_train{listener,story} - recon_UnattendDecoder_audioB_cca_train{listener,story}];
                %
                %             train_data = ...% attend decoder
                %                 [recon_AttendDecoder_audioA_train_cca{listener,story};...
                %                 recon_AttendDecoder_audioB_train_cca{listener,story}];
                
                %              train_data = ...% unattend decoder
                %                 [recon_UnattendDecoder_audioA_train_cca{listener,story};...
                %                 recon_UnattendDecoder_audioB_train_cca{listener,story}];
                
                labels = train_data_labels{listener,story}; % 1 ->attend;0->unattend
                
                % test data
                test_data = ... % attend and unattend decoder
                    [recon_AttendDecoder_audioA_cca(listener,story);...
                    recon_AttendDecoder_audioB_cca(listener,story);...
                    recon_UnattendDecoder_audioA_cca(listener,story);...
                    recon_UnattendDecoder_audioB_cca(listener,story)];
                
                %                 test_data = ... % attend and unattend decoder
                %                     [recon_AttendDecoder_audioA_cca(listener,story) - recon_AttendDecoder_audioB_cca(listener,story);...
                %                     recon_UnattendDecoder_audioA_cca(listener,story) - recon_UnattendDecoder_audioB_cca(listener,story)];
                
                %              test_data = ...% attend decoder
                %                  [recon_AttendDecoder_audioA_cca(listener,story);...
                %                 recon_AttendDecoder_audioB_cca(listener,story)];
                
                %              test_data = ...% unattend decoder
                %                  [recon_UnattendDecoder_audioA_cca(listener,story);...
                %                 recon_UnattendDecoder_audioB_cca(listener,story)];
                
                real_label = ListenA_Or_Not(story,listener);
                
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
        
        
        %     band_name{bandName} = ' broadband 0.5-40Hz long attend decoder';
        % plot
        decoding_acc = mean(decoding_correct_or_not,2);
        plot_name = strcat('CCA sound EEG decoding result+',num2str(timelag(j)),'ms',band_name{bandName},'.jpg');
        plot(decoding_acc*100);
        hold on;
        plot(repmat(mean(decoding_acc*100),[1 12]),'k--');
        title(plot_name(1:end-4));
        xlabel('Subject No.'); ylabel('Decoding Accuarcy %');ylim([0,100]);
        legend('Individual acc','Mean acc')
        saveas(gcf,plot_name);
        close
        
        
        save_name = strcat('CCA_sound_EEG_result+',num2str(timelag(j)),'ms',band_name{bandName},'.mat');
        save(save_name,'decoding_correct_or_not','predict_label_matrix', 'accuracy_total','prob_estimates_total');
        
        
    end
    
    cd(p);
end