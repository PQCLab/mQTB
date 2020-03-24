function k = qtb_sample(p,n)
qrng = qtb_random();
p = p(:);
if n > 1e4 % normal approximation for performance
    mu = p*n;
    sigma = (-p*p'+diag(p))*n;
    k = round(qrng.mvnrnd(mu,sigma));
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
        k(1) = qrng.binornd(n,p(1));
        k(2) = n-k(1);
    else
        k = qrng.mnrnd(n,p);
    end
end
k = k(:);
end

