function phis = get_suborth(psi,dim)

K = size(psi,2);

if K < min(dim)
    phis = get_suborth_sle(psi,dim);
    return;
elseif K > (sum(dim)-length(dim))
    error('Too many vectors. System could not be solved');
end

options = optimset('Display','none');
fval = 1;
while fval > 1e-5
    x0 = rand(2*sum(dim),1);
    [x,fval] = fminsearch(@(x)minfun(x,psi,dim),x0,options);
end
phis = x2states(x,dim);

end

function [phis,phi,norms] = x2states(x,dim)
m = length(dim);
phis = cell(1,m);
norms = zeros(1,m);
phi = 1;
for j = 1:m
    phis{j} = x(1:dim(j)) + 1j*x((1:dim(j))+dim(j));
    norms(j) = norm(phis{j});
    phi = kron(phi,phis{j});
    x(1:(2*dim(j))) = [];
end
end
function F = minfun(x,psi,dim)
[~,phi,norms] = x2states(x,dim);
F = sum(abs(phi'*psi).^2) + sum(norms + 1./norms) - 2*length(norms);
end