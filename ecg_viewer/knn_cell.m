function [idx] = knn_cell(trainData,testData,K)
[~,N] = size(trainData);
%计算训练集与测试集之间的DTW距离dist
dist = zeros(N,1);
trainClass = zeros(N,1);
for i=1:N
    trainClass(i) = trainData{i}(1);
    dist(i,:) = dtw(trainData{i}(2:end)',testData,10);
end
%将dist从小到大进行排序
[Y,I] = sort(dist,1);
K = min(K,length(Y));


%将训练数据对应的类别与训练数据排序结果对应
labels =trainClass(I);
idx = mode(labels(1:K));
% fprintf('该测试数据属于类：%f',idx);
end
    
