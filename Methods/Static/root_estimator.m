function dm = root_estimator(data,meas,r)
%ROOT_ESTIMATOR Root approach estimator
%   Requires MATLAB library https://github.com/PQCLab/RootTomography

if nargin < 3
    r = 'auto';
end

proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
dm = rt_dm_reconstruct(data,proto,'Rank',r);

end

