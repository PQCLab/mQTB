clc;
clear;

dim = [2,2];
% psi = [1;0;0;1]/sqrt(2);
% ca = [1,0;0,1];
% cb = [1,1;1j,-1j]/sqrt(2);
% psi = (kron(ca(:,1),cb(:,1))+kron(ca(:,2),cb(:,2)))/sqrt(2);
% psi = randn(prod(dim),1)+1j*randn(prod(dim),1); psi = psi/norm(psi);
[psi,~] = svd(randn(prod(dim),2)+1j*randn(prod(dim),2),'econ');

phis = get_suborth(psi,dim);
phi = phis{1};
for j = 2:length(phis)
    phi = kron(phi,phis{j});
end
abs(phi'*psi).^2


% [U,S,V] = svd(reshape(psi,dim(1),[]));
% [U,S,V] = svd(transpose(reshape(psi, dim(1),[])), 'econ');
% V = conj(V);
% V = V';
% psi1 = 0;
% for j = 1:dim(1)
%     psi1 = psi1 + S(j,j)*kron(U(:,j),V(:,j));
% end
% norm(psi1)
% abs(psi'*psi1)
% phi1 = null(U(:,1)');
% phi2 = null(conj(V(:,2))');
% abs(kron(phi1,phi2)'*psi)^2