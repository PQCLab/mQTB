function x = qtb_state(type, dim, varargin)

Dim = prod(dim);
input = inputParser;
addRequired(input, 'type');
addRequired(input, 'dim');
addParameter(input, 'rank', Dim);
addParameter(input, 'depol', nan);
parse(input, type, dim, varargin{:});
opt = input.Results;

qrng = qtb_random();
switch type
    case 'random'
        c = qrng.randn([Dim,opt.rank]) + 1j*qrng.randn([Dim,opt.rank]);
        if opt.rank == 1
            x = c*c';
        else
            [U,S] = svd(c,'econ');
            x = U*S*U';
        end
        x = x/trace(x);
    case 'random_vector'
        x = qrng.randn([Dim,1])+1j*qrng.randn([Dim,1]);
        x = x/norm(x);
    case 'random_buhres'
        G = qrng.randn(Dim)+1j*qrng.randn(Dim);
        [U,~] = qr(qrng.randn(Dim)+1j*qrng.randn(Dim));
        A = (eye(Dim)+U)*G;
        x = A*A';
        x = x/trace(x);
    otherwise
        error('Unknown state type: %s', type);
end

if ~isnan(opt.depol)
    p = opt.depol;
    if length(opt.depol) > 1
        p = qrng.rand()*(p(2)-p(1)) + p(1);
    end
    x = (1-p)*x + p*eye(Dim)/Dim;
end

end

