function measset = eorth_proto_eigen(iter,j,n,meas,data,dim)

Dim = prod(dim);
m = Dim+1;
phis = mat2cell(randn(Dim,m) + 1j*randn(Dim,m), Dim, ones(1,m));
proto = cellfun(@(c) vectors2povm(complement_basis(c/norm(c))), phis, 'UniformOutput', false);

if iter > 1
    protocurr = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
    if iter > 2
        dm0 = meas{end}.dm;
    else
        dm0 = 'pinv';
    end
    dm = rt_dm_reconstruct(data, protocurr, 'init', dm0);
    [psi,~] = eig(dm);
    proto{1} = vectors2povm(psi);
end

nshots = ones(1,m)*max(100, floor((j-1)/30));
nleft = n-j+1;
if nleft < sum(nshots)
    nshots = rt_nshots_devide(nleft,m);
end

measset = cellfun(@(povm,n) struct('povm',povm,'nshots',n), proto, num2cell(nshots), 'UniformOutput', false);
if iter > 1
    measset{end}.dm = dm;
end

end
