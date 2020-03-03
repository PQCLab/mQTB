%% Analyze method
proto = qtb_proto('pauli_projectors', 2); % Generate measurement protocol for 2-qubit state tomography
qtb_analyze(...
    @pinvproj_estimator,... % Specify estimator handler
    @(j,n) static_proto(j,n,proto),... % Specify protocol handler
    [2,2], {}, 'name', 'Projected pseudo-iversion', 'file', 'result.mat');

%% Report result
report = qtb_report('result.mat');
disp(['=======> Test result: ', report.rps.name]);
disp(report.rps.resources);
disp(['=======> Test result: ', report.drps.name]);
disp(report.drps.resources);