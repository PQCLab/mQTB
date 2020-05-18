% This examples compares QT methods, presented in examples
% bloch_angles_estimator.m and bloch_vector_estimator.m for an random pure
% states (RPS) test

bloch_angles_estimator;
result_angles = result;

bloch_vector_estimator;
result_vector = result;

report = qtb_compare({result_angles, result_vector}, 'rps', 'names', {'Angles','Vector'}, 'plot', 'percentile');
disp(report.table);
