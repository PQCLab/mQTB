function dm = compsens_estimator(data,meas,dim,method)
%COMPSENS_ESTIMATOR Compressed sensing estimator
%   Requires MATLAB library http://cvxr.com/cvx/

m = length(data);
dim = prod(dim);
Pauli = zeros(m,dim^2);
eta = 0;
for j = 1:m
    Pauli(j,:) = reshape(meas{j}.observable.',1,[]);
    eta = eta + meas{j}.nshots/m;
end
data = cell2mat(data);
data = data(:);

switch method
    case 'lasso'
        mu = 4*sqrt(m/eta);
        warning('off','CVX:Empty')
        cvx_begin sdp quiet
            variable dm(dim,dim) complex semidefinite
            minimize( 2*mu*trace(dm) + pow_pos(norm(Pauli*vec(dm)-data),2) );
        cvx_end
        warning('on','CVX:Empty')
    case 'dantzig'
        data_matrix = reshape(Pauli'*data,dim,dim);
        t = eta*m;
        lambda = 3*dim/sqrt(t);
        A = Pauli'*Pauli;
        warning('off','CVX:Empty')
        cvx_begin sdp quiet
            variable dm(dim,dim) complex semidefinite
            minimize(trace(dm));
            subject to
                (dim/m)*norm(reshape(A*vec(dm),dim,dim)-data_matrix) <= lambda;
        cvx_end
        warning('on','CVX:Empty')
    otherwise
        error('QTB:NoEstimator', 'Unknown estimator');
end

dm = dm/trace(dm);
end

