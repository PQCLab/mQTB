function x = qtb_state(dim, type, varargin)

Dim = prod(dim);
input = inputParser;
addRequired(input, 'dim');
addRequired(input, 'type', @(s)ischar(s));
addParameter(input, 'rank', Dim);
addParameter(input, 'init_err', {});
addParameter(input, 'depol', {});
parse(input, dim, type, varargin{:});
opt = input.Results;

tools = qtb_tools;
stats = qtb_stats;
switch type
    case 'haar_vec'
        x = stats.randn([Dim,1])+1j*stats.randn([Dim,1]);
        x = x/norm(x);
        return;
    case 'haar_dm'
        psi = qtb_state(Dim*opt.rank, 'haar_vec');
        psi = reshape(psi,Dim,opt.rank);
        x = psi*psi';
    case 'bures_dm'
        G = stats.randn(Dim)+1j*stats.randn(Dim);
        U = tools.randunitary(Dim);
        A = (eye(Dim)+U)*G;
        x = A*A';
        x = x/trace(x);
    otherwise
        error('QTB:UnknownGeneratorType', 'Unknown state type: %s', type);
end

if ~isempty(opt.init_err)
    e0 = param_generator(opt.init_err{:});
    v = 1;
    for j = 1:length(dim)
        v = kron(v, [1-e0,e0,zeros(1,dim(j)-2)]);
    end
    [u,w] = eig(x);
    [~,ind] = sort(diag(w),'descend');
    u = u(:,ind);
    x = u*diag(v)*u';
end

if ~isempty(opt.depol)
    p = param_generator(opt.depol{:});
    x = (1-p)*x + p*eye(Dim)/Dim;
end

end

function p = param_generator(type,x1,x2)
    switch type
        case 'fixed'
            p = x1;
        case 'unirnd'
            p = qtb_stats.rand()*(x2-x1) + x1;
        case 'normrnd'
            p = max(0, qtb_stats.randn()*x2 + x1);
        otherwise
            error('QTB:UnknownGeneratorType', 'Unknown depolarization type: %s', type);
    end
end