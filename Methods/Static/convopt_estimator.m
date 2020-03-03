function dm = convopt_estimator(data,dim,proto)
%CONVOPT_ESTIMATOR Convex optimization estimator
%   Requires MATLAB library http://cvxr.com/cvx/

B = [];
p = [];
for j = 1:length(proto)
    M = proto{j};
    B = vertcat(B, reshape(permute(M,[3,2,1]), size(M,3), []));
    p = vertcat(p,data{j}/sum(data{j}));
end

dim = prod(dim);
warning('off','CVX:Empty')
cvx_begin sdp quiet
    variable dm(dim,dim) complex semidefinite
    trace(dm) == 1
    minimize( norm(B*vec(dm)-p) )
cvx_end
warning('on','CVX:Empty')

end

