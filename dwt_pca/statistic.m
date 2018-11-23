a = importdata('pqf_nn.txt');
b = importdata('pqf_svm.txt');
for i = 3:-1:0
    ind = (1:10)*4-i;
    c1 = a(ind,:);
    c2 = b(ind,:);
    d1 = mean(c1);
    d2 = mean(c2);
    f = fopen('1.txt','a');
    fprintf(f,'%10f %10f %10f\n',d1(1),d1(2),d1(3));
    fclose(f);
    f = fopen('2.txt','a');
    fprintf(f,'%10f %10f %10f\n',d2(1),d2(2),d2(3));
    fclose(f);
end
