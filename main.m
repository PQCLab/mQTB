clc;
clear;

N = 10;
n = 1000;

qtb_init('pi4');

for i = 1:N
    disp(i);
    for j = 1:n
        res = qtb_measure_by_states([1; 0]);
        
        % ----- User's tomography procedure
        theta = 2 * pi * rand / sqrt(j);
        U = [cos(theta), -sin(theta); sin(theta), cos(theta)];
        psi = [cos(pi / 8); exp(1i * pi / 4) * sin(pi / 8)];
        psi = U * psi;
        % -----
        
        if (rem(j - 1, 50) == 0)
            qtb_check(psi);
        end
    end
    qtb_restart();
end

qtb_plot();
qtb_plot_split();
F = qtb_last()