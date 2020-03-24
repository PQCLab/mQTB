function [f, msg] = qtb_isdm(dm, tol)

if nargin < 2
    tol = 1e-8;
end
f = false;

if norm(dm-dm')>tol
    msg = 'Density matrix should be Hermitian';
    return;
end

if sum(eig(dm)<-tol)>0
    msg = 'Density matrix shold be non-negative';
    return;
end

if abs(trace(dm)-1)>tol
    msg = 'Density matrix should have a unit trace';
    return;
end

f = true;
msg = '';

end

