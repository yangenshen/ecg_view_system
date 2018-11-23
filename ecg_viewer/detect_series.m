function flag = detect_series(model_name,data)
flag = 0;
model = load(['./model/' model_name '.mat']);
switch model_name
    case 'dwt_pca_model'
        Mdl = model.Mdl;
        [c,l] = wavedec(data,9,'db6');
        [cd3,cd4] = detcoef(c,l,[3 4]);
        fea3 = (cd3'-model.mu3)/(model.W3)';
        fea4 = (cd4'-model.mu4)/(model.W4)';
        fea = [fea3(:,1:6) fea4(:,1:6)];
        label = predict(Mdl,fea);
        if label == 2
            flag = 1;
        end
    case 'dtw_knn_model'
        label = knn(model.train_data(:,2:end),model.train_data(:,1),data,model.k);
        if label == 2
            flag = 1;
        end
    case 'fast_sp_model'
        sp = model.sp;
        th = model.th;
        tmp = 999;
        sp = zscore(sp,1);
        for i = 1:length(data)-length(sp)+1
            norm_data = zscore(data(i:i+length(sp)-1));
            norm_i = norm(norm_data-sp');
            if tmp > norm_i
                tmp = norm_i;
            end
        end
        if tmp > th
            flag = 1;
        end
    case 'dtw_dba_model'
        label = knn_cell(model.train_data',data,model.k);
        if label == 1
           flag = 1; 
        end
end


