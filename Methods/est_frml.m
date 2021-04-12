function fun_est = est_frml()

fun_est = @handler;

end

function dm = handler(meas, data)
    if isfield(meas{end}, 'dm')
        init = meas{end}.dm;
    else
        init = 'pinv';
    end
    proto = cellfun(@(m) m.elem, meas, 'UniformOutput', false);
    dim = size(proto{1}, 1);
    dm = rt_dm_reconstruct(dim, data, proto, 'Rank', 'full', 'init', init);
end
