function dm = ppinv_estimator(data,meas,dim)
%PPINV_ESTIMATOR Projected pseudoinverse estimator

Dim = prod(dim);

M = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
M = cat(3, M{:});
B = reshape(permute(M,[3,2,1]), size(M,3), []);

prob = cellfun(@(kj) kj(:)/sum(kj), data, 'UniformOutput', false);
prob = vertcat(prob{:});

dm = reshape(B\prob,Dim,Dim);
dm = (dm+dm')/2;
dm = dm/trace(dm);
[U,D] = eig(dm);
dm = U*diag(project_probabilities(diag(D)))*U';

end

function p = project_probabilities(p)
a = 0;
[ps,ind] = sort(p,'descend');
for i = length(ps):-1:1
    if ps(i) + a/i >= 0
        ps(1:i) = ps(1:i)+a/i;
        break;
    end
    a = a + ps(i);
    ps(i) = 0;
end
p(ind) = ps;
end