function result = qtb_analyze(fun_proto, fun_est, dim, varargin)
%QTB_ANALYZE Runs the tests to analyze the quantum tomography method.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_analyze.md
%Author: Boris Bantysh, 2020
input = inputParser;
addRequired(input, 'fun_proto');
addRequired(input, 'fun_est');
addRequired(input, 'dim');
addOptional(input, 'tests', 'all', @(s)(ischar(s) || iscell(s)));
addParameter(input, 'mtype', 'povm');
addParameter(input, 'name', 'Untitled QT-method');
addParameter(input, 'max_nsample', inf);
addParameter(input, 'display', true);
addParameter(input, 'filename', 'none');
addParameter(input, 'savefreq', 1);
parse(input, fun_proto, fun_est, dim, varargin{:});
opt = input.Results;
stats = qtb_stats;
tools = qtb_tools;

if opt.display
    disp('Initialization');
end

result = qtb_result(opt.filename, opt.dim, opt.display);
result.load();
result.set_name(opt.name);
result.set_cpu();

% Prepare tests
test_codes = opt.tests;
if ischar(test_codes)
    test_codes = {test_codes};
end
if ~iscell(test_codes)
    error('QTB:TestCodes', 'Test codes must be a cell or string');
end
test_desc = {};
default_tests = qtb_tests.get_all_codes();
for j_test = 1:length(test_codes)
    if ischar(test_codes{j_test})
        if strcmp(test_codes{j_test}, 'all')
            test_desc = horzcat(test_desc, qtb_tests.get_all_tests(opt.dim));
        else
            test_desc{end + 1} = qtb_tests.get_test(test_codes{j_test}, opt.dim);
        end
    else
        test_desc{end + 1} = test_codes{j_test};
    end
end

for j_test = 1:length(test_desc)
    desc = test_desc{j_test};
    desc.nsample = desc.nsample(desc.nsample <= opt.max_nsample);
    result.init_test(desc);
end
result.save();

% Perform tests
for j_test = 1:length(test_desc)
    tcode = test_desc{j_test}.code;
    test = result.tests.(tcode);
    
    if opt.display
        fprintf('===> Running test %d/%d: %s (%s)\n', j_test, length(test_codes), test.name, test.title);
        nb = tools.uprint('');
    end
    
    experiments = result.experiments(tcode);
    for exp_id = 1:length(experiments)
        experiment = experiments{exp_id};
        if ~isnan(experiment.fidelity(1)) % experiment results loaded
            continue;
        end
        stats.set_state(test.seed + experiment.exp_num);
        dm = test.state_fun();
        state = stats.get_state();
        for ntot_id = 1:length(test.nsample)
            ntot = test.nsample(ntot_id);
            if opt.display
                nb = tools.uprint(sprintf('Experiment %d/%d, nsamples = 1e%d', experiment.exp_num, test.nexp, round(log10(ntot))), nb);
            end
            stats.set_state(state);
            [data, meas, time_proto, sm_flag] = tools.simulate_experiment(dm, ntot, opt.fun_proto, opt.dim, opt.mtype);
            experiment.time_proto(ntot_id) = time_proto;
            tic;
            dm_est = tools.call(opt.fun_est, meas, data, opt.dim);
            experiment.time_est(ntot_id) = toc;
            [f,msg] = tools.isdm(dm_est);
            if ~f
                error('QTB:NotDM', ['Estimator error: ', msg]);
            end
            experiment.nmeas(ntot_id) = length(meas);
            experiment.fidelity(ntot_id) = tools.fidelity(dm, dm_est);
            experiment.sm_flag = experiment.sm_flag && sm_flag;
        end
        result.update(tcode, exp_id, experiment);
        if mod(exp_id, opt.savefreq) == 0 || experiment.is_last
            result.save();
        end
    end
    if opt.display
        tools.uprint('Done\n', nb);
    end
end

end

