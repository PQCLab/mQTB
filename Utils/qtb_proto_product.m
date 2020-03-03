function proto = qtb_proto_product(proto,param)

if length(param) == 1 && isnumeric(param)
    proto = cellkronpower(proto,param);
else
    proto = cellkron(proto,param);
end

end

function A = cellkronpower(A0,N)
    A = A0;
    for j = 2:N
        A = cellkron(A,A0);
    end
end

function C = cellkron(A,B)
    ma = length(A);
    mb = length(B);
    C = cell(1,ma*mb);
    for ja = 1:ma
        for jb = 1:mb
            C{(ja-1)*mb+jb} = supkron(A{ja},B{jb});
        end
    end
end

function C = supkron(A,B)
    sa = size3d(A);
    sb = size3d(B);
    C = zeros(sa.*sb);
    for ja = 1:sa(3)
        for jb = 1:sb(3)
            C(:,:,(ja-1)*sb(3)+jb) = kron(A(:,:,ja),B(:,:,jb));
        end
    end
end

function s = size3d(A)
    s(1) = size(A,1);
    s(2) = size(A,2);
    s(3) = size(A,3);
end