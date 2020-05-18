classdef qtb_tools    
%QTB_TOOLS DEfines static tools methods
methods(Static)

function [f, msg] = isdm(dm, tol)
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

function f = isprod(A,dim)
    m = size(A,3);
    f = true(m,1);
    md = length(dim);
    if md == 1
        return;
    end
    for jm = 1:m
        for js = 1:md
            diml = 1;
            if js > 1
                diml = prod(dim(1:(js-1)));
            end
            dims = dim(js);
            dimr = 1;
            if js < md
                dimr = prod(dim((js+1):end));
            end
            Ap = reshape(A(:,:,jm),[dimr,dims,diml,dimr,dims,diml]);
            Ap = permute(Ap,[2,5,1,4,3,6]);
            Ap = reshape(Ap,dims^2,[]);
            f(jm) = f(jm) && (rank(Ap,1e-5) == 1);
            if ~f(jm)
                break;
            end
        end
    end
end

function f = fidelity(a,b)
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

function str = num2str(a)
    if a < 100
        str = num2str(round(a,2,'significant'));
    elseif a >= 1000
        str = fliplr(regexprep(fliplr(num2str(round(a))),'\d{3}(?=\d)', '$0 '));
    else
        str = num2str(round(a));
    end
end

function h = print(str,h)
    if nargin > 1
        fprintf(repmat('\b',1,h.nbytes));
    end
    h.str = str;
    h.nbytes = fprintf(str);
end

function e = get_member(n,elems,dim)
    N = length(elems);
    if N == numel(elems)
        elems = reshape(elems,N,1);
        dim = 1;
    else
        N = size(elems,dim);
    end
    perm = [1,2];
    if dim == 2
        perm = [2,1];
    end
    elems = permute(elems,perm);
    
    ind = mod(n-1,N)+1;
    if iscell(elems) && size(elems,2) == 1
        e = elems{ind};
    else
        e = elems(ind,:);
    end
    e = permute(e,perm);
end

function A = listkronpower(A0,N)
    A = A0;
    for j = 2:N
        A = qtb_tools.listkron(A,A0);
    end
end

function C = listkron(A,B)
    ma = length(A);
    mb = length(B);
    C = cell(1,ma*mb);
    for ja = 1:ma
        for jb = 1:mb
            C{(ja-1)*mb+jb} = qtb_tools.supkron(A{ja},B{jb});
        end
    end
end

function A = kronpower(A0,N)
    A = A0;
    for j = 2:N
        A = kron(A,A0);
    end
end

function C = supkron(A,B)
    sa = size(A); sa(3) = size(A,3);
    sb = size(B); sb(3) = size(B,3);
    C = zeros(sa.*sb);
    for ja = 1:sa(3)
        for jb = 1:sb(3)
            C(:,:,(ja-1)*sb(3)+jb) = kron(A(:,:,ja),B(:,:,jb));
        end
    end
end

function varargout = call(fun,varargin)
    n = nargin(fun);
    if n < 0
        n = length(varargin);
    end
    varargout = cell(1,nargout);
    [varargout{:}] = fun(varargin{1:n});
end

function save_fig(fig, fname)
    ax = fig.CurrentAxes;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    
    saveas(fig, fname);
end

function w = principal(H)
    [u,v] = eig(H);
    v = abs(diag(v));
    w = u(:,v==max(v));
end
function U = randunitary(Dim)
    [Q,R] = qr(qtb_stats.randn(Dim)+1j*qtb_stats.randn(Dim));
    r = diag(R);
    U = Q*diag(r./abs(r));
end

function povm = vec2povm(v)
    d = size(v,1);
    m = size(v,2);
    povm = zeros(d,d,m);
    for j = 1:m
        povm(:,:,j) = v(:,j)*v(:,j)';
    end
end

end
end

