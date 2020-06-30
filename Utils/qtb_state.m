function x = qtb_state(dim, stype, varargin)

Dim = prod(dim);
input = inputParser;
addRequired(input, 'dim');
addRequired(input, 'stype', @(s)ischar(s));
addParameter(input, 'rank', Dim);
addParameter(input, 'init_err', {});
addParameter(input, 'depol', {});
parse(input, dim, stype, varargin{:});
opt = input.Results;

tools = qtb_tools;
stats = qtb_stats;
switch stype
    case 'haar_vec'
        x = stats.randn([Dim,1])+1j*stats.randn([Dim,1]);
        x = x/norm(x);
        return;
    case 'haar_dm'
        psi = qtb_state(Dim*opt.rank, 'haar_vec');
        psi = reshape(psi,Dim,opt.rank);
        [u,w] = svd(psi,'econ');
        w = diag(w).^2;
    case 'bures_dm'
        G = stats.randn(Dim)+1j*stats.randn(Dim);
        U = tools.randunitary(Dim);
        A = (eye(Dim)+U)*G;
        [u,w] = svd(A,'econ');
        w = diag(w).^2;
        w = w/sum(w);
    otherwise
        error('QTB:UnknownGeneratorType', 'Unknown state type: %s', stype);
end
u = qtb_tools.complete_basis(u);
if length(w) < Dim
    w = [w; zeros(Dim-length(w),1)];
end

if ~isempty(opt.init_err)
    e0 = param_generator(opt.init_err{:});
    w = 1;
    for j = 1:length(dim)
        w = kron(w, [1-e0;e0;zeros(dim(j)-2,1)]);
    end
end

if ~isempty(opt.depol)
    p = param_generator(opt.depol{:});
    w = (1-p)*w + p/Dim;
end

x = u*diag(w)*u';
end

function p = param_generator(ptype,x1,x2)
    switch ptype
        case 'fixed'
            p = x1;
        case 'unirnd'
            p = qtb_stats.rand()*(x2-x1) + x1;
        case 'normrnd'
            p = max(0, qtb_stats.randn()*x2 + x1);
        otherwise
            error('QTB:UnknownGeneratorType', 'Unknown depolarization type: %s', ptype);
    end
end