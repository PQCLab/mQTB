classdef qtb_tools    
%QTB_TOOLS Defines static tools methods
methods(Static)

function [data, meas, time_proto, sm_flag] = simulate_experiment(dm, ntot, fun_proto, dim, mtype, asymp)
    if nargin < 6
        asymp = false;
    end
    data = {};
    meas = {};
    time_proto = 0;
    sm_flag = true;
    jn = 0;
    while jn < ntot
        tic;
        meas_curr = qtb_tools.call(fun_proto, jn, ntot, meas, data, dim);
        time_proto = time_proto + toc;
        if ~isfield(meas_curr,'nshots')
            meas_curr.nshots = 1;
        end
        if (jn + meas_curr.nshots) > ntot
            error('QTB:NShots', 'Number of measurements exceeds available sample size');
        end
        sm_flag = sm_flag && all(qtb_tools.isprod(meas_curr.(mtype),dim));
        data{end+1} = qtb_tools.get_measurement_data(dm, meas_curr, mtype, asymp);
        meas{end+1} = meas_curr;
        jn = jn + meas_curr.nshots;
    end
end

function data = get_measurement_data(dm, meas_curr, mtype, asymp)
    tol = 1e-8;
    switch mtype
        case 'povm'
            m = size(meas_curr.povm,3);
            prob = zeros(m,1);
            for k = 1:m
                prob(k) = real(trace(dm*meas_curr.povm(:,:,k)));
            end
            extraop = false;
            probsum = sum(prob);
            if any(prob < 0)
                if any(prob < -tol)
                    error('QTB:ProbNeg', 'Measurement operators are not valid: negative eigenvalues exist');
                end
                prob(prob < 0) = 0;
                probsum = sum(prob);
            end
            if probsum > 1+tol
                error('QTB:ProbGT1', 'Measurement operators are not valid: total probability is greater than 1');
            end
            if probsum < 1-tol
                extraop = true;
                prob = [prob; 1-probsum];
            end
            if asymp
                clicks = prob*meas_curr.nshots;
            else
                clicks = qtb_stats.sample(prob, meas_curr.nshots);
            end
            if extraop
                clicks = clicks(1:(end-1));
            end
            data = clicks;
        case 'operator'
            meas_curr.povm =  meas_curr.operator;
            clicks = qtb_tools.get_measurement_data(dm, meas_curr, 'povm', asymp);
            data = clicks(1);
        case 'observable'
            [U,D] = eig(meas_curr.observable);
            meas_curr.povm = zeros(size(U,1),size(U,1),size(U,2));
            for k = 1:size(U,2)
                meas_curr.povm(:,:,k) = U(:,k)*U(:,k)';
            end
            clicks = qtb_tools.get_measurement_data(dm, meas_curr, 'povm', asymp);
            data = clicks'*diag(D)/meas_curr.nshots;
        otherwise
            error('Unknown measurement type');
    end
end    

function [f, msg] = isdm(dm, tol)
    if nargin < 2
        tol = 1e-8;
    end
    f = false;

    if ~isnumeric(dm) || (size(dm, 1) ~= size(dm, 2))
        msg = 'Input is not a valid square numeric matrix';
        return;
    end
    
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
    a = a / trace(a);
    b = b / trace(b);
    [u,d] = svd(a);
    sqa = u*sqrt(d)*u';
    A = sqa * b * sqa;
    f = real(sum(sqrt(svd(A)))^2);
    if f > 1 % fix computation inaccuracy
        f = 2-f;
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

function nb = uprint(str, nb)
    if nargin > 1
        fprintf(repmat('\b',1,nb));
    end
    nb = fprintf(str);
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

function [val, c] = get_field(c, fname, def_value)
    for j = 1:length(c)
        if ischar(c{j}) && strcmpi(c{j}, fname) && j < length(c)
            val = c{j+1};
            c([j,j+1]) = [];
            return;
        end
    end
    val = def_value;
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
function u = randunitary(Dim)
    [q,r] = qr(qtb_stats.randn(Dim)+1j*qtb_stats.randn(Dim));
    r = diag(r);
    u = q*diag(r./abs(r));
end
function u = complete_basis(u)
    [d,m] = size(u);
    if m >= d
        return;
    end
    [q,r] = qr([u, qtb_stats.randn([d,d-m])+1j*qtb_stats.randn([d,d-m])]);
    r = diag(r);
    u = q*diag(r./abs(r));
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

