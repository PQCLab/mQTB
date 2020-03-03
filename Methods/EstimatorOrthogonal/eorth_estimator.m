function dm = eorth_estimator(data,meas,~)

proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
if isfield(meas{end},'dm')
    dm0 = meas{end}.dm;
else
    dm0 = 'pinv';
end

dm = rt_dm_reconstruct(data, proto, 'init', dm0);

end

