clc;
clear;

d = 36;
[U,~] = svd(randn(d)+1j*randn(d));

tic;
vectors2povm(U);
toc;
tic;
pr = cellfun(@(x)x*x', mat2cell(U,d,ones(1,d)), 'UniformOutput', false);
cat(3,pr{:});
toc;