function k = qtb_sample(p,n)
try
p = p(:);
if n > 1e4 % normal approximation for performance
    Mu = p*n;
    Sigm = (-p*p'+diag(p))*n;
    s = eig(Sigm);
    indn = s<0;
    if any(indn)
        Sigm = Sigm - min(s(indn)); % fix small negative eigenvalues
    end
    k = round(mvnrnd(Mu,Sigm));
    k(k<0) = 0;
    if sum(k)>n
        kmind = (k==max(k));
        k(kmind) = k(kmind) - (sum(k)-n);
    else
        k(end) = n-sum(k(1:(end-1)));
    end
else
    if length(p) == 2
        k = zeros(2,1);
        k(1) = binornd(n,p(1));
        k(2) = n-k(1);
    else
        k = mnrnd(n,p);
    end
end
k = k(:);
catch
    save('error_report.mat','p','n');
    error('Error reported');
end
end

