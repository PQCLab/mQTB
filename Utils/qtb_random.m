function h = qtb_random()

h.seed = @seed_;
h.rand = @rand_;
h.randn = @randn_;
h.binornd = @binornd_;
h.mnrnd = @mnrnd_;
h.mvnrnd = @mvnrnd_;

end

function seed_(n)
    rng(n,'twister');
end

function x = rand_(sz)
    if nargin == 0
        sz = 1;
    end
    x = rand(sz);
end

function x = randn_(sz)
    if nargin == 0
        sz = 1;
    end
    x = norminv(rand_(sz));
end

function x = binornd_(n,p,sz)
    if nargin < 3
        sz = 1;
    end
    x = sum(rand_([sz,n]) < p, length(sz)+1);
end

function x = mnrnd_(n,p)
    edges = cumsum(p(:)/sum(p));
    edges = [0; edges];
    x = histcounts(rand_([n,1]),edges);
    x = x(:);
end

function x = mvnrnd_(mu, sigma)
    T = chol(sigma+1e-10);
    x = T*randn_([length(mu),1]) + mu(:);
end