clc;
clear;

A = 0;
a = 3;
b = 0.1;
s = 0.602;
t = 0.101;

dim = 2;
psi0 = [1;0];
n_iter = 100;
nshots = 1000;

% psi_true = randstate;
psi_true = [-0.1115 + 0.0956*1j; 0.9892];
r_true = blochVector(psi_true*psi_true');

psi = psi0;
r = zeros(3,n_iter);
for k = 1:n_iter
    bet = b/(k+1)^t;
    alp = a/(k+1+A)^s;
    delta = rand(dim,1) + 1j*rand(dim,1);
%     delta = ((rand(dim,1)>0.5)-1) + 1j*((rand(dim,1)>0.5)-1);
    
    psi_proj = psi + bet*delta;
    psi_proj = psi_proj / sqrt(psi_proj'*psi_proj);
%     E_plus = abs(psi_proj'*psi_true)^2;
    E_plus = binornd(nshots,min(1,abs(psi_proj'*psi_true)^2))/nshots;
    
    psi_proj = psi - bet*delta;
    psi_proj = psi_proj / sqrt(psi_proj'*psi_proj);
%     E_minus = abs(psi_proj'*psi_true)^2;
    E_minus = binornd(nshots,min(1,abs(psi_proj'*psi_true)^2))/nshots;
    
    grad = (E_plus - E_minus)/(2*bet);
    
    psi = psi + alp*grad*delta;
    psi = psi / sqrt(psi'*psi);
    r(:,k) = blochVector(psi*psi');
end
r = [blochVector(psi0*psi0'), r];
dF = 1-fidelityB(psi,psi_true)
% return;
figure;
[X,Y,Z] = sphere(20);
surf(X,Y,Z,'FaceColor','none');
hold on;
plot3(r(1,:),r(2,:),r(3,:),'LineWidth',1.5);
scatter3(r_true(1),r_true(2),r_true(3),'filled');
axis equal;