function fun_est = est_frls()

fun_est = @handler;

end

function dm = handler(meas,data,dim)
Dim = prod(dim);

M = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
M = cat(3, M{:});
B = reshape(permute(M,[3,2,1]), size(M,3), []);

prob = cellfun(@(kj) kj(:)/sum(kj), data, 'UniformOutput', false);
prob = vertcat(prob{:});

warning('off','CVX:Empty')
cvx_begin sdp quiet
    variable dm(Dim,Dim) complex semidefinite
    trace(dm) == 1
    minimize( norm(B*vec(dm)-prob) )
cvx_end
warning('on','CVX:Empty')

[U,D] = svd(dm);
dm = U*(D/trace(D))*U';
end
