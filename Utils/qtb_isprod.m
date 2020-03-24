function f = qtb_isprod(A,dim)

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
        f(jm) = f(jm) && (rank(Ap) == 1);
        if ~f(jm)
            break;
        end
    end
end

end

