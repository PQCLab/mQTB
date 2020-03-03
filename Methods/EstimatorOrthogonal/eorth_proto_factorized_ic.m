function measset = eorth_proto_factorized_ic(iter,j,n,meas,data,dim,baseproto)

N = length(dim);
if iter > 1
    protocurr = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
    if iter > 2
        dm0 = meas{end}.dm;
    else
        dm0 = 'pinv';
    end
    dm = rt_dm_reconstruct(data, protocurr, 'init', dm0);
    [psi,lam] = eig(dm);
    [~,ind] = sort(diag(lam),'descend');
    K = randi(sum(dim)-length(dim));
    phis = get_suborth(psi(:,ind(1:K)),dim);
    proto = {1};
    [phi,~] = svd(baseproto{1}(:,:,1));
    phi = phi(:,1);
    for j_phi = 1:length(phis)
        proto1 = baseproto;
        [u,~,v] = svd(phis{j_phi}*phi');
        U = u*v';
        for k1 = 1:length(proto1)
            for k2 = 1:size(proto1{k1},3)
                proto1{k1}(:,:,k2) = U*proto1{k1}(:,:,k2)*U';
            end
        end
        proto = qtb_proto_product(proto,proto1);
    end
else
    proto = qtb_proto_product(baseproto,N);
end

m = length(proto);
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

