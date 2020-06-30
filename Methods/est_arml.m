function fun_est = est_arml(sl)

if nargin == 0
    sl = 0.05;
end
fun_est = @(meas,data) handler(meas,data,sl);

end

function dm = handler(meas,data,sl)

proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
dm = rt_dm_reconstruct(data,proto,'SignificanceLevel',sl);

end