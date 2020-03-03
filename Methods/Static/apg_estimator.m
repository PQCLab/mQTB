function dm = apg_estimator(data,meas)
%APG_ESTIMATOR Quantum state estimation via accelerated projected gradient
%   Requires MATLAB library https://github.com/qMLE/qMLE

operators = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
operators = cat(3, operators{:});
f = cellfun(@(fj) fj(:), data, 'UniformOutput', false);
f = vertcat(f{:});

dm = qse_apg(operators, f);

end

