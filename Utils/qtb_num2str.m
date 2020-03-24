function str = qtb_num2str(a)

if a < 100
    str = num2str(round(a,2,'significant'));
elseif a >= 1000
    str = fliplr(regexprep(fliplr(num2str(round(a))),'\d{3}(?=\d)', '$0 '));
else
    str = num2str(round(a));
end

end

