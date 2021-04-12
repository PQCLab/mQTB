function fun_est = est_trml(r)

fun_est = @(meas,data) handler(meas, data, r);

end

function dm = handler(meas,data,r)

proto = cellfun(@(m) m.elem, meas, 'UniformOutput', false);
dm = rt_dm_reconstruct(data, proto, 'Rank',r);

end