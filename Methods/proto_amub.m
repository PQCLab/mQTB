function fun_proto = proto_amub(d, fun_est)

proto = qtb_proto(['mub',num2str(d)]);
fun_proto = iterative_proto(@get_measset, proto.elems, proto.info.vectors{1}, fun_est);

end

function measset = get_measset(iter,jn,ntot,meas,data,dim,base_proto,phi,fun_est)

proto = base_proto;
m = length(proto);
if iter > 1
    dm = qtb_tools.call(fun_est, meas, data, dim);
    [u,~] = svd(dm);
    u = u*phi';
    for j = 1:m
        for k = 1:size(proto{j},3)
            proto{j}(:,:,k) = u*proto{j}(:,:,k)*u';
        end
    end
end

nshots = ones(1,m)*max(100,floor(jn/30));
nleft = ntot-jn;
if nleft < sum(nshots)
    nshots = ones(1,m)*floor(nleft/m);
    nshots(end) = nleft - sum(nshots(1:(end-1)));
end

measset = cellfun(@(povm,n) struct('povm',povm,'nshots',n), proto, num2cell(nshots), 'UniformOutput', false);
if iter > 1 && jn > 1e4
    measset{end}.dm = dm;
end

end