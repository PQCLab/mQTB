function x = qtb_join_data(x)

x0 = x;
x = [];
for j = 1:size(x0,1)
    x = horzcat(x, permute(x0(j,:,:),[2,3,1]));
end

end

