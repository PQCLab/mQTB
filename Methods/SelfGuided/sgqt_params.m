n_iter = 1e3;
A = 10^length(dim)-10;
a = 3;
b = 0.1;
s = 0.602;
t = 0.101;
% delta_fun = @(dim) randn(prod(dim),1) + 1j*randn(prod(dim),1);
delta_fun = @(dim) 2*((rand(dim,1)>0.5)-1) + 1j*2*((rand(dim,1)>0.5)-1);