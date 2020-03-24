clc;
clear;

dim = [3,3];
K = 2;
% psi1 = randn(prod(dim),1)+1j*randn(prod(dim),1); psi1 = psi1/norm(psi1);
% psi2 = randn(prod(dim),1)+1j*randn(prod(dim),1); psi2 = psi2/norm(psi2);
% psi3 = randn(prod(dim),1)+1j*randn(prod(dim),1); psi3 = psi3/norm(psi3);
% psi = [psi1,psi2];
[psi,~] = svd(rand(prod(dim)) + 1j*rand(prod(dim)));
psi = psi(:,1:K);

% psi_re = [real(psi);imag(psi)];
% phi2 = randn(dim(2),1) + 1j*randn(dim(2),1);
% w = kron(eye(dim(1)),phi2);
% A = psi_re'*[real(w);imag(w)];
% s = 1;
% a1 = A(:,1:s);
% a2 = A(:,(s+1):end);
% x2 = randn(size(a2,2),1);
% x1 = -a1\(a2*x2);
% x = [x1;x2]
% 
% 
% return;
% phi1re = randn(2*dim(2),1);
% Are = psi

phi2 = randn(dim(2),1) + 1j*randn(dim(2),1);
A = psi'*kron(eye(dim(1)),phi2);
A = [real(A), -imag(A); imag(A) real(A)];
s = 6;
a1 = A(:,1:s);
a2 = A(:,(s+1):end);
if isempty(a2)
    [~,~,v] = svd(a1);
    x1 = v(:,end);
    x2 = [];
else
    x2 = randn(size(a2,2),1);
    if a1 == 0
        x1 = randn + 1j*randn;
    else
        x1 = -a1\(a2*x2);
    end
end
x = [x1;x2];
phi1 = sum(reshape(x,[],2)*[1,0;0,1j],2);
phi1 = phi1/norm(phi1);
phi2 = phi2/norm(phi2);
phi = kron(phi1,phi2);
abs(phi'*psi).^2

return;
% K = size(psi,2);
% phis = cell(1,length(dim));
% ind = find(dim==min(dim),1);
% B = 1;
% for j = 1:length(dim)
%     if j == ind
%         B = kron(B,eye(dim(j)));
%     else
%         phis{j} = randn(dim(j),1)+1j*randn(dim(j),1);
%         phis{j} = phis{j}/norm(phis{j});
%         B = kron(B,phis{j});
%     end
% end
% A = psi'*B;
% a1 = A(:,1:K);
% a2 = A(:,(K+1):end);
% x2 = randn(size(a2,2),1)+1j*randn(size(a2,2),1);
% b = -a2*x2;
% x1 = a1\b;
% phis{ind} = [x1;x2];
% phis{ind} = phis{ind}/norm(phis{ind});

phis = get_suborth(psi,dim);
phi = phis{1};
for j = 2:length(phis)
    phi = kron(phi,phis{j});
end
abs(phi'*psi).^2

return;
c2 = randn(dim(2),1)+1j*randn(dim(2),1);
c2 = c2/norm(c2);

A = psi'*kron(eye(dim(1)),c2);
a1 = A(:,1:K);
a2 = A(:,(K+1):end);

x2 = randn(size(a2,2),1)+1j*randn(size(a2,2),1);
b = -a2*x2;
x1 = a1\b;
c1 = [x1;x2];
c1 = c1/norm(c1);

abs(kron(c1,c2)'*psi).^2
return;
[U,S,V] = svd(transpose(reshape(psi,[],dim(1))));
V = conj(V);

% c1 = randn(dim(1),1)+1j*randn(dim(1),1);
% c1 = c1/norm(c1);


c2 = randn(dim(2),1)+1j*randn(dim(2),1);
c2 = c2/norm(c2);
v = S*c2;
c1 = randn(dim(1),1)+1j*randn(dim(1),1);
s = min(dim);
c1(1) = -transpose(c1(2:s))*v(2:s)/v(1);
c1 = c1/norm(c1);

% [phi,coeff] = svd([c1, c2],'econ');
% [c1, c2]
% phi
% S
% coeff

phi1 = U*c1;
phi2 = V*c2;
abs(kron(phi1,phi2)'*psi)^2

return;
c2 = randn(dim(1),1)+1j*randn(dim(1),1);
c2 = c2/norm(c2);
c1 = null(transpose(c2.*diag(S)));
c1 = c1(:,1);

phi1 = U*c1;
phi2 = V*c2;

abs(kron(phi1,phi2)'*psi)^2
% kron(phi1,phi2)'*S(1,1)*kron(U(:,1),V(:,1))
% kron(phi1,phi2)'*S(2,2)*kron(U(:,2),V(:,2))