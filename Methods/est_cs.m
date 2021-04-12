function fun_est = est_cs(mtype)
%COMPSENS_ESTIMATOR Compressed sensing estimator
%   Requires MATLAB library http://cvxr.com/cvx/

if nargin < 1
    mtype = 'observable';
end

switch mtype
    case 'observable'
        fun_est = @handler_observable;
    case 'povm'
        fun_est = @handler_povm;
end

end

function dm = handler_observable(meas, data, dim)
Dim = prod(dim);

% fake identity operator measurement
meas{end+1} = struct('elem', eye(Dim), 'nshots', meas{end}.nshots);
data{end+1} = 1;

m = length(data);
Pauli = zeros(m, Dim^2);
N = 0;
for j = 1:m
    Pauli(j,:) = reshape(meas{j}.elem.', 1, []);
    N = N + meas{j}.nshots;
end
data = cell2mat(data);
data = data(:);

mu = 4*m/sqrt(N);
warning('off','CVX:Empty')
cvx_begin sdp quiet
	variable dm(Dim,Dim) complex semidefinite
	minimize( 2*mu*trace(dm) + pow_pos(norm(Pauli*vec(dm) - data), 2) );
cvx_end
warning('on','CVX:Empty')

[U,D] = svd(dm);
dm = U*(D/trace(D))*U';
end

function dm = handler_povm(meas, data, dim)
Dim = prod(dim);

M = cellfun(@(m) m.nshots * m.elem, meas, 'UniformOutput', false);
M = cat(3, M{:});
A = reshape(permute(M,[3,2,1]), size(M,3), []);

y = cell2mat(data);
N = repmat(sum(y,1), size(y,1), 1);
y = y(:);
N = N(:);

eps0 = sqrt(sum(y.*(1-y./N)));
dm = nan(Dim);
alp = 0;
while isnan(dm(1,1))
    eps = eps0*(1+alp);
    warning('off','CVX:Empty')
    cvx_begin sdp quiet
        variable dm(Dim,Dim) complex semidefinite
        minimize(trace(dm))
        subject to
            norm(real(A*vec(dm))-y) <= eps
    cvx_end
    warning('on','CVX:Empty')
    alp = alp + 0.1;
end

[U,D] = svd(dm);
dm = U*(D/trace(D))*U';
end