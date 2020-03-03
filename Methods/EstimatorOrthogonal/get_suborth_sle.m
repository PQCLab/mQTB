function phis = get_suborth_sle(psi,dim)

K = size(psi,2);
phis = cell(1,length(dim));
ind = find(dim==min(dim),1);
if K >= dim(ind)
    error('Too many vectors. System could not be solved');
end

B = 1;
for j = 1:length(dim)
    if j == ind
        B = kron(B,eye(dim(j)));
    else
        phis{j} = randn(dim(j),1)+1j*randn(dim(j),1);
        phis{j} = phis{j}/norm(phis{j});
        B = kron(B,phis{j});
    end
end
A = psi'*B;
a1 = A(:,1:K);
a2 = A(:,(K+1):end);
if isempty(a2)
    [~,~,v] = svd(a1);
    x1 = v(:,end);
    x2 = [];
else
    x2 = randn(size(a2,2),1)+1j*randn(size(a2,2),1);
    if a1 == 0
        x1 = randn + 1j*randn;
    else
        x1 = -a1\(a2*x2);
    end
end
phis{ind} = [x1;x2];
phis{ind} = phis{ind}/norm(phis{ind});

end
