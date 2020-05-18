function dm = est_arml(meas,data)

proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
dm = rt_dm_reconstruct(data,proto,'Rank','auto');

end

