function measurement = static_proto(j, n, proto, mtype, ratio)

if nargin < 4
    mtype = 'povm';
end
if nargin < 5
    ratio = ones(1,length(proto))/length(proto);
end
cdf = cumsum(ratio/sum(ratio));
ind = find(j/n <= cdf, 1);
measurement.(mtype) = proto{ind};
if ind == length(cdf)
    measurement.nshots = n - j + 1;
else
    measurement.nshots = floor(cdf(ind)*n) - j + 1;
end

end

