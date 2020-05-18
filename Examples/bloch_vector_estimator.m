% This examples analyzes a QT method that estimates the normalized Bloch
% vector that corresponds to a mixed state

result = qtb_analyze(proto_pauli(1), @estimator, 2, 'rps', 'mtype', 'observable'); % analyze
report = qtb_report(result, 'rps', 'plot', true); % make a report
disp(report.table); % show table for different banchmark fidelities

% Estimator function
function dm = estimator(~,data)
    r = cell2mat(data);
    r = r/norm(r);
    dm = [1+r(3), r(1)-1j*r(2);
        r(1)+1j*r(2), 1-r(3)]/2;
end