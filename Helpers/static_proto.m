function fun_proto = static_proto(proto)

mtype = proto.mtype;
elems = proto.elems;
if isfield(proto,'ratio')
    ratio = proto.ratio;
else
    ratio = ones(1,length(elems))/length(elems);
end
cdf = cumsum(ratio/sum(ratio));

fun_proto = @(jn,ntot) handler(jn,ntot,elems,mtype,cdf);

end

function measurement = handler(jn, ntot, elems, mtype, cdf)

ind = find((jn+1)/ntot <= cdf, 1);
measurement.(mtype) = elems{ind};
if ind == length(cdf)
    measurement.nshots = ntot - jn;
else
    measurement.nshots = floor(cdf(ind)*ntot) - jn;
end

end

