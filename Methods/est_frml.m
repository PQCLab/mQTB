function dm = est_frml(meas,data)

proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
dm = rt_dm_reconstruct(data,proto,'Rank','full');

end

