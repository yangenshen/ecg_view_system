function  labels_tr  = digit2lable(digits,labels)
    labels_tr=digits;
    for i = 1:length(digits)
        digit = digits(i);
        minus_digit = abs(labels-digit);
        labels_tr(i) = labels(find(minus_digit==min(minus_digit)));
    end
end

