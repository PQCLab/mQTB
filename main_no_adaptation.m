clc;
clear;

qtb_init('pi4');

N_exp = 20;
N = 10000;

s0 = [1; 0];
s1 = [0; 1];

tic;
for i = 1:N_exp
    disp(i);
    
    result0 = qtb_measure_by_states([s0, s1], N);
%     result1 = qtb_measure_by_states(repmat(s1, 1, N));
    
    theta = 0.01;
    U = [cos(theta), -sin(theta); sin(theta), cos(theta)];
    psi = U * [cos(pi / 8); exp(1i * pi / 4) * sin(pi / 8)];
    
    qtb_check(psi);
    qtb_restart();
end
toc;

qtb_last()