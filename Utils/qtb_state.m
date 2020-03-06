function dm = qtb_state(type, dim, varargin)

Dim = prod(dim);
input = inputParser;
addRequired(input, 'type');
addRequired(input, 'dim');
addParameter(input, 'rank', Dim);
addParameter(input, 'depol', nan);
parse(input, type, dim, varargin{:});
opt = input.Results;

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
    p = opt.depol;
    if length(opt.depol) > 1
        p = rand*(p(2)-p(1)) + p(1);
    end
    dm = (1-p)*dm + p*eye(Dim)/Dim;
end

end

