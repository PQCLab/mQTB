function dm = cgls_estimator(data,meas)
%CGLS_ESTIMATOR Quantum state estimation via conjugate gradients with line search
%   Requires MATLAB library https://github.com/qMLE/qMLE

operators = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
operators = cat(3, operators{:});
f = cellfun(@(fj) fj(:), data, 'UniformOutput', false);
f = vertcat(f{:});

dm = qse_cgls(operators, f);


end

