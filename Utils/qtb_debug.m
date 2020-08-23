function info = qtb_debug(fun_proto, fun_est, dim, ntot, varargin)
%QTB_DEBUG Runs a single quantum tomography and returns complete information.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_debug.md
%Author: Boris Bantysh, 2020
input = inputParser;
addRequired(input, 'fun_proto');
addRequired(input, 'fun_est');
addRequired(input, 'dim');
addRequired(input, 'ntot', @(n)(isnumeric(n) && n >= 1 && n == round(n))||isinf(n));
addOptional(input, 'test', 'none', @(s)ischar(s));
addParameter(input, 'dm', 'none');
addParameter(input, 'mtype', 'povm');
parse(input, fun_proto, fun_est, dim, ntot, varargin{:});
opt = input.Results;
tools = qtb_tools;

if strcmpi(opt.test, 'none')
    [f,msg] = tools.isdm(opt.dm);
    if ~f
        error('QTB:NotDM', ['Error using `dm` field: ', msg]);
    end
    dm = opt.dm;
else
    test_desc = qtb_tests(opt.dim);
    if isfield(test_desc, opt.test)
        dm = qtb_state(opt.dim, test_desc.(opt.test).generator{:});
    else
        error('QTB:UnknownTest', 'Test with test code `%s` does not exists', test);
    end
end

asymp = false;
if isinf(opt.ntot)
    asymp = true;
end
[data, meas, time_proto, sm_flag] = tools.simulate_experiment(dm, opt.ntot, opt.fun_proto, opt.dim, opt.mtype, asymp);
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
info.asymp = asymp;
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

