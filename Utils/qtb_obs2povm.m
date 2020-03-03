function [povm, eigvals] = qtb_obs2povm(obs)
%QTB_OBS2PROJ Converts observables to POVM operators as projectors
%
%   [povm, eigvals] = qtb_obs2povm(obs) returns POVM operators by
%   observable matrix and a column-vector of corresponding observable
%   eigenvalues
%
%   [Povm, Eigvals] = qtb_obs2povm(Obs) returns cell arrays of POVM
%   operators and corresponding eigenvalues for a number of observables.
%   Obs{j} is the j-th observable.

if iscell(obs)
    povm = cell(size(obs));
    eigvals = cell(size(obs));
    for j = 1:length(obs)
        [povm{j}, eigvals{j}] = qtb_obs2proj(obs{j});
    end
else
    [U,D] = eig(obs);
    povm = zeros(size(U,1),size(U,1),size(U,2));
    for k = 1:size(U,2)
        povm(:,:,k) = U(:,k)*U(:,k)';
    end
    eigvals = diag(D);
end



end

