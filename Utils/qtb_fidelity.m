function f = qtb_fidelity(a,b)
%QTB_FIDELITY Calculates the fidelity of quantum states
%   Calculates the fidelity of the states `a` and `b`. If both inputs are
%   column-vectors the result is the scalar product. If one of the inputs
%   is the density matrix the result is the expectation value for the
%   density matrix. If both inputs are density matrices the result is the
%   Ulhman's fidelity.

if size(a,2) > 1 && size(b,2) > 1
    a = a / trace(a);
    b = b / trace(b);
    [u,d] = eig(a);
    sd = sqrt(d);
    A = u*sd*u' * b * u*sd*u';
    f = real(sum(sqrt(eig(A)))^2);
    if f > 1 % fix computation inaccuracy
        f = 2-f;
    end
elseif size(a,2) > 1
    a = a / trace(a);
    b = b / sqrt(b'*b);
    f = abs(b'*a*b);
elseif size(b,2) > 1
    a = a / sqrt(a'*a);
    b = b / trace(b);
    f = abs(a'*b*a);
else
    f = abs(a'*b)^2;
end

end

