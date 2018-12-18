function dist_windom = dtw_custom(t,r,w)
n = size(t,1);
m = size(r,1);
w = max(w,abs(n-m));%窗口,保证终点在对角线窗口之内
%距离矩阵
d = zeros(n,m);
for i = 1:n
    for j = max(1,i-w):min(m,i+w)
        d(i,j) = (t(i,:)-r(j,:)).^2;
    end
end
%累积矩阵or cost matrix
D = ones(n,m)*realmax;
D(1,1) = d(1,1);
for i = 2:n
    for j = max(1,i-w):min(m,i+w)
        D1 = D(i-1,j);
        if j>1
            D2 = D(i-1,j-1);
            D3 = D(i,j-1);
        else
            D2 = realmax;
            D3 = realmax;
        end
        D(i,j) = d(i,j)+min([D1,D2,D3]);
    end
end
dist_windom = D(n,m);

            

