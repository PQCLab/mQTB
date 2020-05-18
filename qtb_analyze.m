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
addParameter(input, 'display', true);
addParameter(input, 'file', 'none');
addParameter(input, 'savefreq', 1);
parse(input, fun_proto, fun_est, dim, varargin{:});
opt = input.Results;

if opt.display
    disp('Initialization');
end

% Load previous data
rsave = false;
if ~strcmp(opt.file,'none')
    rsave = true;
    if length(opt.file) < 5 || ~strcmpi(opt.file((end-3):end), '.mat')
        opt.file = [opt.file, '.mat'];
    end
    if isfile(opt.file)
        load(opt.file,'result');
        if ~isequal(result.dim, opt.dim)
            error('QTB:DimMismatch', 'Failed to load results file: dimensions mismatch');
        end
        fprev = [opt.file, '.asv'];
        save(fprev, 'result');
        if opt.display
            fprintf('Results file loaded with tests:\n%s\nPrevious version available as %s\n', 'TODO', fprev);
        end
    end
end
result.name = opt.name;
result.dim = opt.dim;
result.lib = 'mQTB';

% Generate test list
test_desc = qtb_tests(opt.dim);
test_codes = opt.tests;
if ischar(test_codes)
    if strcmp(test_codes, 'all')
        test_codes = fieldnames(test_desc);
    else
        test_codes = {test_codes};
    end
end

% Prepare tests
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = test_desc.(tcode);
    hash = DataHash(test);
    if isfield(result,tcode)
        if strcmp(result.(tcode).hash, hash)
            continue;
        else
            if opt.display
                warning('QTB:TestFingerprintMismatch', 'Failed to load results for test %s: fingerprint mismatch.\nThese results will be overwritten\n', test.code);
            end
        end
    end
    test.hash = hash;
    test.fidelity = nan(test.nexp, length(test.nsample));
    test.nmeas = zeros(test.nexp, length(test.nsample));
    test.time_proto = zeros(test.nexp, length(test.nsample));
    test.time_est = nan(test.nexp, length(test.nsample));
    test.sm_flag = true;
    result.(tcode) = test;
end

% Perform tests
stats = qtb_stats;
tools = qtb_tools;
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = result.(tcode);
    if opt.display
        fprintf('===> Running test %d/%d: %s (%s)\n', j_test, length(test_codes), test.name, test.code);
        fprintf('Progress: ');
        h = tools.print('');
    end
    
    for j_exp = 1:test.nexp
        stats.seed(test.seed+j_exp);
        dm = qtb_state(opt.dim, test.generator{:});
        for j_ntot = 1:length(test.nsample)
            if ~isnan(test.fidelity(j_exp,j_ntot)) % experiment loaded
                continue;
            end
            ntot = test.nsample(j_ntot);
            if opt.display
                h = tools.print(sprintf('experiment %d/%d, nsamples = 1e%d', j_exp, test.nexp, round(log10(ntot))), h);
            end
            [data,meas,time_proto,sm_flag] = conduct_experiment(dm, ntot, opt.fun_proto, opt.dim, opt.mtype);
            test.time_proto(j_exp,j_ntot) = time_proto;
            test.sm_flag = test.sm_flag && sm_flag;
            
            tic;
            dm_est = tools.call(opt.fun_est,meas,data,opt.dim);
            test.time_est(j_exp,j_ntot) = toc;
            [f,msg] = tools.isdm(dm_est);
            if ~f; error('QTB:NotDM', ['Estimator error: ', msg]); end
            
            test.fidelity(j_exp,j_ntot) = tools.fidelity(dm, dm_est);
            test.nmeas(j_exp,j_ntot) = length(meas);
            result.(tcode) = test;
        end
        if rsave && (mod(j_exp, opt.savefreq) == 0 || j_exp == test.nexp)
            save(opt.file, 'result');
        end
    end
    if opt.display
        tools.print('done\n', h);
    end
end

if opt.display
    fprintf('All tests are finished!\n\n');
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
