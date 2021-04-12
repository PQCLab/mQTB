function info = qtb_debug(fun_proto, fun_est, dim, ntot, test)
%QTB_DEBUG Runs a single quantum tomography and returns complete information.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_debug.md
%Author: Boris Bantysh, 2020
input = inputParser;
addRequired(input, 'fun_proto');
addRequired(input, 'fun_est');
addRequired(input, 'dim');
addRequired(input, 'ntot', @(n)(isnumeric(n) && n >= 1 && n == round(n)) || isinf(n));
addRequired(input, 'test', @(s)(ischar(s) || isstruct(s)));
parse(input, fun_proto, fun_est, dim, ntot, test);
opt = input.Results;
tools = qtb_tools;

if ischar(opt.test)
    opt.test = qtb_tests.get_test(opt.test, dim);
end

dm = tools.call(opt.test.fun_state);
[data, meas, time_proto, sm_flag] = tools.simulate_experiment(dm, opt.ntot, opt.fun_proto, opt.test.fun_meas, opt.dim);
tic;
dm_est = tools.call(opt.fun_est, meas, data, opt.dim);
time_est = toc;
[f,msg] = tools.isdm(dm_est);
if ~f
    error('QTB:NotDM', ['Estimator error: ', msg]);
end
nmeas = length(meas);
fidelity = tools.fidelity(dm, dm_est);

info.options = opt;
info.dm = dm;
info.meas = meas;
info.data = data;
info.nmeas = nmeas;
info.sm_flag = sm_flag;
info.time_proto = time_proto;
info.time_est = time_est;
info.dm_est = dm_est;
info.fidelity = fidelity;

end

