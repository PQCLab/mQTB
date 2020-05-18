function dm = est_cs(meas,data,dim)
%COMPSENS_ESTIMATOR Compressed sensing estimator
%   Requires MATLAB library http://cvxr.com/cvx/

Dim = prod(dim);

m = length(data);
Pauli = zeros(m,Dim^2);
N = 0;
for j = 1:m
    Pauli(j,:) = reshape(meas{j}.observable.',1,[]);
    N = N + meas{j}.nshots;
end
data = cell2mat(data);
data = data(:);

mu = 4*m/sqrt(N);
warning('off','CVX:Empty')
cvx_begin sdp quiet
	variable dm(Dim,Dim) complex semidefinite
	minimize( 2*mu*trace(dm) + pow_pos(norm(Pauli*vec(dm)-data),2) );
cvx_end
warning('on','CVX:Empty')

dm = dm/trace(dm);
end

