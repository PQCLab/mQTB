% This examples analyzes a QT method that estimates spherical angles theta
% and phi that correspond to a pure state on a Bloch sphere

result = qtb_analyze(proto_fmub(2), @estimator, 2, 'rps'); % analyze
report = qtb_report(result, 'rps', 'plot', true); % make a report
disp(report.table); % show table for different banchmark fidelities

% Estimator function
function dm = estimator(meas,data)
    px = data{1}(1)/meas{1}.nshots;
    py = data{2}(1)/meas{2}.nshots;
    pz = data{3}(1)/meas{3}.nshots;
    tet = acos(2*pz-1);
    phi = angle((2*px-1)+1j*(2*py-1));
    psi = [cos(tet/2); sin(tet/2)*exp(1j*phi)];
    dm = psi*psi';
end