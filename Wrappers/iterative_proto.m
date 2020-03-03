function measurement = iterative_proto(fun_proto,j,n,meas,varargin)

newiter = false;
if isempty(meas)
    newiter = true;
    iter = 1;
    start = 1;
    current = 1;
else
    iter = meas{end}.iter;
    start = meas{end}.iter_start;
    current = meas{end}.iter_current + 1;
    itlen = meas{end}.iter_length;
    nsample = meas{end}.iter_nsample;
    
    if current > itlen
        newiter = true;
        iter = iter + 1;
        start = length(meas) + 1;
        current = 1;
        itlen = nan;
        nsample = nan;
    end
end

if newiter
    measset = fun_proto(iter,j,n,meas,varargin{:});
    if ~iscell(measset)
        measset = {measset};
    end
    measurement = measset{1};
    measurement.measset = measset;
    itlen = length(measset);
    nsample = sum(cellfun(@(m) m.nshots, measset));
else
    measurement = meas{start}.measset{current};
end

measurement.iter = iter;
measurement.iter_start = start;
measurement.iter_current = current;
measurement.iter_length = itlen;
measurement.iter_nsample = nsample;

end

