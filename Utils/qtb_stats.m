classdef qtb_stats
    
properties (Constant)
    rng = RandStream('mt19937ar')
end

%QTB_STATS Define static methods to work with statistics   
methods(Static)

% Random number generators
function set_state(state)
    if length(state) > 1
        qtb_stats.rng.set('State', state);
    else
        qtb_stats.rng.reset(state);
    end
end

function state = get_state()
    state = qtb_stats.rng.get('State');
end

function x = rand(sz)
    if nargin == 0
        sz = 1;
    end
    x = qtb_stats.rng.rand(sz);
end

function x = randn(sz)
    if nargin == 0
        sz = 1;
    end
    x = norminv(qtb_stats.rand(sz));
end

function x = binornd(n,p,sz)
    if nargin < 3
        sz = 1;
    end
    x = sum(qtb_stats.rand([sz,n]) < p, length(sz)+1);
end

function x = mnrnd(n,p)
    edges = cumsum(p(:)/sum(p));
    edges = [0; edges];
    x = histcounts(qtb_stats.rand([n,1]),edges);
    x = x(:);
end

function x = mvnrnd(mu, sigma)
    try
    T = chol(sigma+1e-8);
    catch
        1;
    end
    x = T'*qtb_stats.randn([length(mu),1]) + mu(:);
end

% Generating sample
function k = sample(p,n)
    stats = qtb_stats();
    p = p(:);
    if n > 1e4 % normal approximation for performance
        mu = p*n;
        sigma = (-p*p'+diag(p))*n;
        k = round(stats.mvnrnd(mu,sigma));
        k(k<0) = 0;
        if sum(k)>n
            kmind = find(k==max(k),1);
            k(kmind) = k(kmind) - (sum(k)-n);
        else
            k(end) = n-sum(k(1:(end-1)));
        end
    else
        if length(p) == 2
            k = zeros(2,1);
            k(1) = stats.binornd(n,p(1));
            k(2) = n-k(1);
        else
            k = stats.mnrnd(n,p);
        end
    end
    k = k(:);
end

% Adjusted whisker box
function abox = awhiskerbox(data, dim)
    if nargin < 2
        if size(data,1) == 1
            dim = 2;
        else
            dim = 1;
        end
    end
    
    if dim ~= 1
        perm = 1:ndims(data);
        perm(1) = dim;
        perm(dim) = 1;
        data = permute(data, perm);
    end
    
    sd = size(data);
    data = reshape(data, sd(1), prod(sd(2:end)));
    Q = quantile(data,[0.25,0.5,0.75], 1);
    abox.med = Q(2,:);
    abox.q25 = Q(1,:);
    abox.q75 = Q(3,:);
    abox.iqr = abox.q75-abox.q25;
    
    [abox.mc, abox.w1, abox.w2] = deal(zeros(1,size(data,2)));
    abox.isout = false(size(data));
    for j = 1:size(data,2)
        abox.mc(j) = qtb_stats.medcouple(data(:,j));
        if abox.mc(j) > 0
            abox.w1(j) = abox.q25(j)-1.5*abox.iqr(j)*exp(-4*abox.mc(j));
            abox.w2(j) = abox.q75(j)+1.5*abox.iqr(j)*exp(3*abox.mc(j));
        else
            abox.w1(j) = abox.q25(j)-1.5*abox.iqr(j)*exp(-3*abox.mc(j));
            abox.w2(j) = abox.q75(j)+1.5*abox.iqr(j)*exp(4*abox.mc(j));
        end
        abox.isout(:,j) = (data(:,j)<abox.w1(j) | data(:,j)>abox.w2(j));
    end
    
    fnames = fieldnames(abox);
    for j = 1:length(fnames)
        fname = fnames{j};
        if strcmp(fname,'isout')
            abox.(fname) = reshape(abox.(fname), sd);
        else
            abox.(fname) = reshape(abox.(fname), 1, prod(sd(2:end)));
        end
        if dim ~= 1
            abox.(fname) = permute(abox.(fname), perm);
        end
    end
end

function mc = medcouple(x)
    x = sort(x);
    L = length(x);
    med = (x(floor((L+1)/2)) + x(ceil((L+1)/2)))/2;

    xp = x(x >= med);
    xm = x(x <= med);
    [Xm, Xp] = meshgrid(xm, xp);

    lp = length(xp);
    lq = length(xm);
    [Im, Ip] = meshgrid(0:(lq-1),0:(lp-1));

    I = (Xp == med & Xm == med);
    Xp = Xp(~I); Xm = Xm(~I);
    H = zeros(size(I));
    H(~I) = ((Xp-med)-(med-Xm))./(Xp-Xm);
    H(I) = sign(lp-1-Ip(I)-Im(I));

    h = sort(H(:));
    L = length(h);
    mc = (h(floor((L+1)/2)) + h(ceil((L+1)/2)))/2;
end

function b = get_bound(nsample, dim, r, type, p)
    Dim = prod(dim);
    if nargin < 4
        type = 'mean';
    end
    nu = (2*Dim-r)*r - 1;
    switch type
        case 'mean'
            b = nu^2./(4*nsample*(Dim-1));
        case 'std'
            b = nu^2./(4*nsample*(Dim-1))*sqrt(2*nu);
        case 'percentile'
            b = chi2inv(p/100, nu)*nu./(4*nsample*(Dim-1));
        otherwise
            error('QTB:BoundType', 'Unknown bound type');
    end
end

end
end

