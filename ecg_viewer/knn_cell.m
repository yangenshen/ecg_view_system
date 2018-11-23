function [idx] = knn_cell(trainData,testData,K)
[~,N] = size(trainData);
%����ѵ��������Լ�֮���DTW����dist
dist = zeros(N,1);
trainClass = zeros(N,1);
for i=1:N
    trainClass(i) = trainData{i}(1);
    dist(i,:) = dtw(trainData{i}(2:end)',testData,10);
end
%��dist��С�����������
[Y,I] = sort(dist,1);
K = min(K,length(Y));


%��ѵ�����ݶ�Ӧ�������ѵ��������������Ӧ
labels =trainClass(I);
idx = mode(labels(1:K));
% fprintf('�ò������������ࣺ%f',idx);
end
    
