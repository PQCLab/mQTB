function fun_proto = proto_amub(d, fun_est)

proto = qtb_proto(['mub',num2str(d)]);
phi = qtb_tools.principal(proto.elems{1}(:,:,1));
fun_proto = iterative_proto(@get_measset, proto.elems, phi, fun_est);

end

function measset = get_measset(iter,jn,ntot,meas,data,dim,proto,phi,fun_est)

m = length(proto);
if iter > 1
    dm = qtb_tools.call(fun_est,meas,data,dim);
    psi = qtb_tools.principal(dm);
    [u,~,v] = svd(psi*phi');
    U = u*v';
    for j = 1:m
        for k = 1:size(proto{j},3)
            proto{j}(:,:,k) = U*proto{j}(:,:,k)*U';
        end
    end
end

nshots = ones(1,m)*max(100,floor(jn/30));
nleft = ntot-jn;
if nleft < sum(nshots)
    nshots = floor(ones(1,m)*(nleft/m));
    nshots(end) = nleft - sum(nshots(1:(end-1)));
end

measset = cellfun(@(povm,n) struct('povm',povm,'nshots',n), proto, num2cell(nshots), 'UniformOutput', false);

end