function measurement = eorth_proto_factorized(j,n,meas,data,dim)

Dim = prod(dim);
N = length(dim);
if N == 1
    error('Single-system case not supported. Try @eorth_proto_factorized_ic.');
end

iter = length(meas);
if iter > 1
    proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
    if iter > Dim^2
        dm0 = meas{end}.dm;
    else
        dm0 = 'pinv';
    end
    dm = rt_dm_reconstruct(data,proto,'init',dm0);
    [psi,lam] = eig(dm);
    [~,ind] = sort(diag(lam),'descend');
    K = randi(sum(dim)-length(dim));
    phis = get_suborth(psi(:,ind(1:K)),dim);
    u = 1;
    for j_phi = 1:length(phis)
        u = kron(u, complement_basis(phis{j_phi}));
    end
else
    u = eye(Dim);
end

nshots = max(100, floor((j-1)/30));
nshots = min(n-j+1, nshots);

measurement.povm = vectors2povm(u);
measurement.nshots = nshots;
if iter > 1
    measurement.dm = dm;
end

end

