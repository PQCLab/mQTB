function povm = vectors2povm(psi)
d = size(psi,1);
m = size(psi,2);
povm = zeros(d,d,m);
for j = 1:m
    povm(:,:,j) = psi(:,j)*psi(:,j)';
end
end

