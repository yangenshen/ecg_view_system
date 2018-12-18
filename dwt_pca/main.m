train_file = 'F:/Heartbeat Classification/datasets_mitdb_10_24/datasets_mitdb_10_24/221_rawA_TRAIN';
test_file = 'F:/Heartbeat Classification/datasets_mitdb_10_24/datasets_mitdb_10_24/221_rawA_TEST';
train_signals = importdata(train_file);
test_signals = importdata(test_file);

[M_train,N_train] = size(train_signals);
[M_test,N_test] = size(test_signals);

all_seg_train = train_signals(:,2:end);
all_labels_train = train_signals(:,1);
all_seg_test = test_signals(:,2:end);
all_labels_test = test_signals(:,1);
ffd_neurals = 5;
% clc
fprintf(strcat('-------------',string(ffd_neurals),'-------------\n'))
for ll = 1:10
    % dwt extract features
    P = 6;
    fea_dwt3_train = zeros(M_train,34);
    fea_dwt4_train = zeros(M_train,22);
    fea_dwt3_test = zeros(M_test,34);
    fea_dwt4_test = zeros(M_test,22);
    
    for i = 1:M_train
        s = all_seg_train(i,:);
        [c,l] = wavedec(s,9,'db6');
        [cd3,cd4] = detcoef(c,l,[3 4]);
        fea_dwt3_train(i,:) = cd3;
        fea_dwt4_train(i,:) = cd4;
    end
    
    for i = 1:M_test
        s = all_seg_test(i,:);
        [c,l] = wavedec(s,9,'db6');
        [cd3,cd4] = detcoef(c,l,[3 4]);
        fea_dwt3_test(i,:) = cd3;
        fea_dwt4_test(i,:) = cd4;
    end
    
    % pca dimensionality reduction
    wt3 = var(fea_dwt3_train);
    mu3 = mean(fea_dwt3_train);
    [W3,fea_pca3] = pca(fea_dwt3_train,'VariableWeights',wt3);
    wt4 = var(fea_dwt4_train);
    mu4 = mean(fea_dwt4_train);
    [W4,fea_pca4] = pca(fea_dwt4_train,'VariableWeights',wt4);
    fea_pca_train = [fea_pca3(:,1:6) fea_pca4(:,1:6)]; % M * 12

    fea_dwt3_test = fea_dwt3_test-mu3;
    fea_dwt4_test = fea_dwt4_test-mu4;
    fea_pca3 = fea_dwt3_test/W3';
    fea_pca4 = fea_dwt4_test/W4';

    fea_pca_test = [fea_pca3(:,1:6) fea_pca4(:,1:6)]; % M * 12
    
    % HOS
%     maxlag = 8;
%     flag = 'unbaised';
%     overlap = 0;
%     k1=2;k2=2;
%     
%     fea_hos_train = zeros(M_train,(maxlag*2+1)*2);
%     nsamp = N_train-1;
%     for i = 1:M_train
%         s = all_seg_train(i,:);
%         fea_hos3 = cum3est (s, maxlag, nsamp, overlap, flag, k1);
%         fea_hos4 = cum4est (s, maxlag, nsamp, overlap, flag, k1, k2);
%         fea_hos_train(i,:) = [fea_hos3' fea_hos4'];
%     end
%     
%     fea_hos_test = zeros(M_test,(maxlag*2+1)*2);
%     nsamp = N_test-1;
%     for i = 1:M_test
%         s = all_seg_test(i,:);
%         fea_hos3 = cum3est (s, maxlag, nsamp, overlap, flag, k1);
%         fea_hos4 = cum4est (s, maxlag, nsamp, overlap, flag, k1, k2);
%         fea_hos_test(i,:) = [fea_hos3' fea_hos4'];
%     end
%     
%     % ICA
%     Q = 16;
%     fea_hos_train = prewhiten(fea_hos_train);
%     Mdl = rica(fea_hos_train,Q);
%     fea_ica_train = transform(Mdl,fea_hos_train);
%     
%     fea_hos_test = prewhiten(fea_hos_test);
%     Mdl = rica(fea_hos_test,Q);
%     fea_ica_test = transform(Mdl,fea_hos_test);
%     
    
    % combination
    fea_train = [ fea_pca_train ]; % M * 12
    fea_test = [ fea_pca_test];
    
    % NN
    net = feedforwardnet(ffd_neurals);
    net.trainFcn = 'trainlm';
%     net.trainParam.lr = 0.1;
    net.trainParam.goal = 10e-20;
    net.trainParam.epochs = 10000;
    net.trainParam.max_fail = 6;
    [net,tr] = train(net,fea_train',all_labels_train');
    nn_digits_test = net(fea_test');
    nn_labels_test = digit2lable(nn_digits_test,unique(all_labels_test));
    nn_acc = sum(all_labels_test==nn_labels_test')/M_test;
    % SVM

    Mdl = svmtrainn(all_labels_train,fea_train,'-t 2');
    save('param.mat','W3','W4','mu3','mu4','Mdl');
    svm_labels_test = predict(Mdl,fea_test);
    svm_acc = sum(all_labels_test==svm_labels_test)/M_test;
    % P R F1
    C_nn = confusionmat(all_labels_test,nn_labels_test);
    C_svm =  confusionmat(all_labels_test,svm_labels_test);
    for j = 1:length(unique(all_labels_train))
        P_nn = C_nn(j,j)/sum(C_nn(:,j));
        if(isnan(P_nn)) 
            P_nn = 0; 
        end
        P_svm = C_svm(j,j)/sum(C_svm(:,j));
        if(isnan(P_svm)) 
            P_svm = 0; 
        end
        R_nn = C_nn(j,j)/sum(C_nn(j,:));
        if(isnan(R_nn)) 
            R_nn = 0; 
        end
        R_svm = C_svm(j,j)/sum(C_svm(j,:));
        if(isnan(R_svm)) 
            R_svm = 0; 
        end
        F_nn = P_nn*R_nn*2/(P_nn+R_nn);
        if(isnan(F_nn)) 
            F_nn = 0; 
        end
        F_svm = P_svm*R_svm*2/(P_svm+R_svm);
        if(isnan(F_svm)) 
            F_svm = 0; 
        end
        f = fopen('pqf_nn.txt','a');
        fprintf(f,'%10f %10f %10f\n',P_nn,R_nn,F_nn);
        fclose(f);
        f = fopen('pqf_svm.txt','a');
        fprintf(f,'%10f %10f %10f\n',P_svm,R_svm,F_svm);
        fclose(f);
    end
    fprintf(strcat('The acc of NN is ', string(nn_acc),'\n'));
    fprintf(strcat('The acc of SVM is ', string(svm_acc),'\n'));
end