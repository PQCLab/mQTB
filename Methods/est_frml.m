function fun_est = est_frml()

fun_est = @handler;

end

function dm = handler(meas, data)
    if isfield(meas{end}, 'dm')
        init = meas{end}.dm;
    else
        init = 'pinv';
    end
    proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
    dm = rt_dm_reconstruct(data,proto,'Rank','full','init',init);
end
