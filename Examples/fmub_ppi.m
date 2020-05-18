% The following code shows the basic example of running analysis for a
% 2-qubit tomography method on random pure states
dim = [2,2];
result = qtb_analyze(proto_fmub(dim), @est_ppi, dim, 'rps');

% The following code calculates benchmarks using raw data obtained above
report = qtb_report(result, 'rps', 'plot', true);
disp(report.table);