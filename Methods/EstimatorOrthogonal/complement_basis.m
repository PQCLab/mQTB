function U = complement_basis(psi)

Dim = length(psi);
U = [psi, randn(Dim,Dim-1)+1j*randn(Dim,Dim-1)];
[U,~] = qr(U);

end

