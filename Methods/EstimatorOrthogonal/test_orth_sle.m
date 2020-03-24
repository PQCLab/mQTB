clc;
clear;

dim = [2,2,2];
K = 3;
[psi,~] = svd(rand(prod(dim)) + 1j*rand(prod(dim)));
psi = psi(:,1:K);

phis = get_suborth(psi,dim);
phi = phis{1};
for j = 2:length(phis)
    phi = kron(phi,phis{j});
end
abs(phi'*psi).^2


% x01 = zeros(2*dim(1),1); x01(1) = 1;
% x02 = zeros(2*dim(2),1); x02(1) = 1;
% x0 = [x01;x02];
% 
% options = optimset('Display','iter','TolFun',1e-6,'TolX',1e-8);
% x = fminsearch(@(x)minfun(x,psi,dim),x0,options);
% [phi1,phi2] = x2states(x,dim);
% abs(kron(phi1,phi2)'*psi).^2

% phi = get_suborth(psi,dim);
% abs(kron(phi{1},phi{2})'*psi).^2

% [U,S,V] = svd(transpose(reshape(psi,[],dim(1))), 'econ');
% V = conj(V);
% abs(phi1'*U)
% abs(phi2'*V)


% function [phi1,phi2] = x2states(x,dim)
% phi1 = x(1:dim(1)) + 1j*x((1:dim(1))+dim(1));
% x(1:(2*dim(1))) = [];
% phi2 = x(1:dim(2)) + 1j*x((1:dim(2))+dim(2));
% phi1 = phi1/norm(phi1);
% phi2 = phi2/norm(phi2);
% end
% function F = minfun(x,psi,dim)
% [phi1,phi2] = x2states(x,dim);
% F = sum(abs(kron(phi1,phi2)'*psi).^2);
% end