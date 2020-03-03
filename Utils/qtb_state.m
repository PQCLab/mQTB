function dm = qtb_state(type, dim, varargin)

input = inputParser;
addRequired(input, 'type');
addRequired(input, 'dim');
addParameter(input, 'rank', dim);
addParameter(input, 'depol', nan);
parse(input, type, dim, varargin{:});
opt = input.Results;

Dim = prod(dim);
switch type
    case 'random'
        c = randn(Dim,opt.rank) + 1j*randn(Dim,opt.rank);
        [U,S] = svd(c,'econ');
        dm = U*S*U';
        dm = (dm+dm')/2;
        dm = dm/trace(dm);
    case 'random_buhres'
        G = randn(Dim)+1j*randn(Dim);
        [U,~] = qr(randn(Dim)+1j*randn(Dim));
        A = (eye(Dim)+U)*G;
        dm = A*A';
        dm = dm/trace(dm);
    otherwise
        error('Unknown state type: %s', type);
end

if ~isnan(opt.depol)
    dm = (1-opt.depol)*dm + opt.depol*eye(dim)/dim;
end

end

