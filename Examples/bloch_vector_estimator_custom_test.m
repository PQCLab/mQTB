% This examples analyzes a QT method that estimates the normalized Bloch
% vector that corresponds to a mixed state

custom_test = qtb_tests.create_test(2, ...
                                    @pi4_state, ...
                                    0, ...
                                    'code', 'custom', ...
                                    'title', 'Custom', ...
                                    'name', 'My custom test', ...
                                    'nsample', [100, 1000, 10000], ...
                                    'rank', 1);

result = qtb_analyze(proto_pauli(1), @estimator, 2, {custom_test, 'rps'}, 'mtype', 'observable');

report_custom = qtb_report(result, 'custom', 'plot', true);
report_rps = qtb_report(result, 'rps', 'plot', true); 
disp(report_custom.table); 
disp(report_rps.table)


% Estimator function
function dm = estimator(~,data)
    r = cell2mat(data);
    r = r/norm(r);
    dm = [1+r(3), r(1)-1j*r(2);
        r(1)+1j*r(2), 1-r(3)]/2;
end

% State generator function
function dm = pi4_state()
    e = 0.05;
    phi = pi / 4 + e * rand();
    theta = pi / 4 + e * rand();
    psi = [cos(theta / 2); exp(1i * phi) * sin(theta / 2)];
    dm = psi * psi';
end