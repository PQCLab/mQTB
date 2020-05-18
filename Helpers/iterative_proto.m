function fun_proto = iterative_proto(fun_measset, varargin)

fun_proto = @(jn,ntot,meas,data,dim) handler(fun_measset,jn,ntot,meas,data,dim,varargin{:});

end

function measurement = handler(fun_proto,jn,ntot,meas,varargin)

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
    
    if current > itlen
        newiter = true;
        iter = iter + 1;
        start = length(meas) + 1;
        current = 1;
        itlen = nan;
    end
end

if newiter
    measset = qtb_tools.call(fun_proto,iter,jn,ntot,meas,varargin{:});
    if ~iscell(measset)
        measset = {measset};
    end
    measurement = measset{1};
    measurement.measset = measset;
    itlen = length(measset);
else
    measurement = meas{start}.measset{current};
end

measurement.iter = iter;
measurement.iter_start = start;
measurement.iter_current = current;
measurement.iter_length = itlen;

end

