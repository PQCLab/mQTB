function measurement = static_proto(j, n, proto, varargin)

if isempty(varargin)
    ratio = ones(1,length(proto))/length(proto);
else
    ratio = varargin{1};
end
cdf = cumsum(ratio/sum(ratio));
ind = find(j/n <= cdf, 1);
measurement.povm = proto{ind};

if ind == length(cdf)
    measurement.nshots = n - j + 1;
else
    measurement.nshots = floor(cdf(ind)*n) - j + 1;
end

end

