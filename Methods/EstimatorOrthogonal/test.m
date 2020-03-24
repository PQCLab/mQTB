clc;
clear;

dim = [2,2];
K = 2;
[psi,~] = svd(rand(prod(dim)) + 1j*rand(prod(dim)));
psi = psi(:,1:K);

v = null(psi');
v = v(:,1:2);
a = v(1,1)*v(4,1)-v(2,1)*v(3,1);
b = v(1,1)*v(4,2)+v(4,1)*v(1,2)-v(2,1)*v(3,2)-v(3,1)*v(2,2);
c = v(1,2)*v(4,2)-v(2,2)*v(3,2);
D = b^2-4*a*c;
x = (-b+sqrt(D))/(2*a);
c = [x;1];
phi = v*c;

phi1 = kron(eye(2),[1;0])'*phi + kron(eye(2),[0;1])'*phi;
phi1 = phi1/norm(phi1);

phi2 = kron([1;0],eye(2))'*phi + kron([0;1],eye(2))'*phi;
phi2 = phi2/norm(phi2);

abs(kron(phi1,phi2)'*psi)