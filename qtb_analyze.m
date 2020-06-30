function result = qtb_analyze(fun_proto, fun_est, dim, varargin)
%QTB_ANALYZE Runs the tests to analyze the quantum tomography method.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_analyze.md
%Author: Boris Bantysh, 2020
input = inputParser;
addRequired(input, 'fun_proto');
addRequired(input, 'fun_est');
addRequired(input, 'dim');
addOptional(input, 'tests', 'all', @(s)(ischar(s) || iscellstr(s)));
addParameter(input, 'mtype', 'povm');
addParameter(input, 'name', 'Untitled QT-method');
addParameter(input, 'max_nsample', inf);
addParameter(input, 'display', true);
addParameter(input, 'filename', 'none');
addParameter(input, 'savefreq', 1);
parse(input, fun_proto, fun_est, dim, varargin{:});
opt = input.Results;

if opt.display
    disp('Initialization');
end

result = qtb_result(opt.filename, opt.dim, opt.display);
result.load();
result.set_name(opt.name);
result.set_cpu();

% Prepare tests
test_desc = qtb_tests(opt.dim);
test_codes = opt.tests;
if ischar(test_codes)
    if strcmp(test_codes, 'all')
        test_codes = fieldnames(test_desc);
    else
        test_codes = {test_codes};
    end
end

for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = test_desc.(tcode);
    test.nsample = test.nsample(test.nsample <= opt.max_nsample);
    result.init_test(tcode, test);
end
result.save();

% Perform tests
stats = qtb_stats;
tools = qtb_tools;
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = result.tests.(tcode);
    
    if opt.display
        fprintf('===> Running test %d/%d: %s (%s)\n', j_test, length(test_codes), test.name, test.code);
        nb = tools.uprint('');
    end
    
    experiments = result.experiments(tcode);
    for exp_id = 1:length(experiments)
        experiment = experiments{exp_id};
        if ~isnan(experiment.fidelity(1)) % experiment results loaded
            continue;
        end
        stats.set_state(test.seed + experiment.exp_num);
        dm = qtb_state(opt.dim, test.generator{:});
        state = stats.get_state();
        for ntot_id = 1:length(test.nsample)
            ntot = test.nsample(ntot_id);
            if opt.display
                nb = tools.uprint(sprintf('Experiment %d/%d, nsamples = 1e%d', experiment.exp_num, test.nexp, round(log10(ntot))), nb);
            end
            stats.set_state(state);
            [data, meas, experiment.time_proto(ntot_id), sm_flag] = conduct_experiment(dm, ntot, opt.fun_proto, opt.dim, opt.mtype);
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

function [data,meas,time_proto,sm_flag] = conduct_experiment(dm, ntot, fun_proto, dim, mtype, asymp)
    if nargin < 6
        asymp = false;
    end
    data = {};
    meas = {};
    time_proto = 0;
    sm_flag = true;
    jn = 0;
    while jn < ntot
        tic;
        meas_curr = qtb_tools.call(fun_proto, jn, ntot, meas, data, dim);
        time_proto = time_proto + toc;
        if ~isfield(meas_curr,'nshots')
            meas_curr.nshots = 1;
        end
        if (jn + meas_curr.nshots) > ntot
            error('QTB:NShots', 'Number of measurements exceeds available sample size');
        end
        sm_flag = sm_flag && all(qtb_tools.isprod(meas_curr.(mtype),dim));
        data{end+1} = get_data(dm, meas_curr, mtype, asymp);
        meas{end+1} = meas_curr;
        jn = jn + meas_curr.nshots;
    end
end

function data = get_data(dm, meas_curr, mtype, asymp)
    tol = 1e-8;
    switch mtype
        case 'povm'
            m = size(meas_curr.povm,3);
            prob = zeros(m,1);
            for k = 1:m
                prob(k) = real(trace(dm*meas_curr.povm(:,:,k)));
            end
            extraop = false;
            probsum = sum(prob);
            if any(prob < 0)
                if any(prob < -tol)
                    error('QTB:ProbNeg', 'Measurement operators are not valid: negative eigenvalues exist');
                end
                prob(prob < 0) = 0;
                probsum = sum(prob);
            end
            if probsum > 1+tol
                error('QTB:ProbGT1', 'Measurement operators are not valid: total probability is greater than 1');
            end
            if probsum < 1-tol
                extraop = true;
                prob = [prob; 1-probsum];
            end
            
            if asymp
                clicks = prob*meas_curr.nshots;
            else
                clicks = qtb_stats.sample(prob, meas_curr.nshots);
            end
            if extraop
                clicks = clicks(1:(end-1));
            end
            data = clicks;
        case 'operator'
            meas_curr.povm =  meas_curr.operator;
            clicks = get_data(dm, meas_curr, 'povm', asymp);
            data = clicks(1);
        case 'observable'
            [U,D] = eig(meas_curr.observable);
            meas_curr.povm = zeros(size(U,1),size(U,1),size(U,2));
            for k = 1:size(U,2)
                meas_curr.povm(:,:,k) = U(:,k)*U(:,k)';
            end
            clicks = get_data(dm, meas_curr, 'povm', asymp);
            data = clicks'*diag(D)/meas_curr.nshots;
        otherwise
            error('Unknown measurement type');
    end
end
