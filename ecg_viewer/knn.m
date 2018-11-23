function [idx] = knn(trainData,trainClass,testData,K)
[N,~] = size(trainData);
%����ѵ��������Լ�֮���DTW����dist
dist = zeros(N,1);
for i=1:N
    dist(i,:) = dtw(trainData(i,:)',testData,1);
end
%��dist��С�����������
[Y,I] = sort(dist,1);
K = min(K,length(Y));
%��ѵ�����ݶ�Ӧ�������ѵ��������������Ӧ
labels =trainClass(I);
idx = mode(labels(1:K));
% fprintf('�ò������������ࣺ%f',idx);
end
    
