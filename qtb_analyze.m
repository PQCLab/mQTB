function result = qtb_analyze(fun_est, fun_proto, dim, varargin)
%QTB_ANALYZE Runs the tests to analyze the quantum tomography (QT) method.
%The measurements are described in terms of POVM-operators.
%
%   result = qtb_abalyze(fun_est, fun_proto, dim) performs the all-tests
%   analysis of the QT-method specified by function handlers `fun_est` and
%   `fun_proto`. `dim` is the dimension array
%
%   result = qtb_abalyze(fun_est, fun_proto, dim, T) additionally specifies
%   the tests list T (character cell array).
%
%   result = qtb_abalyze( ___ ,Name,Value)  specifies line properties using
%   one or more Name,Value pair arguments. Available arguments:
%       • Name (string) - specifies the method name. Default: 'Untitled
%       QT-method'
%       • File (string) - filename to save and load analysis result.
%       Default: 'none'
%       • Load (boolean) - reconstruct density matrix by the
%       pseudo-inversion only. Default: true
%
%OUTPUT:
%   result - structure array with analysis result. Fields:
%       • result.dim - dimention array
%       • result.name - method name
%       • restult.(tcode) - structure array of the test `tcode` results
%
%%Formating
%The dimension array describes the dimension of the each subsystem. For
%example, `dim=2` stands for a single qubit system, `dim=[2,3]` -
%qubit+qutrit system.
%
%The measurement array is a cell array of struct arrays describing the 
%measurements: `meas{j}.povm(:,:,k)` is the k-th POVM operator of a j-th
%measurement, `meas{j}.nshots` is the number of measurement tries.
%
%The data array is a cell array containing measurement results:
%`data{j}(k)` is the number of outcomes for k-th POVM operator of j-th
%measurement. For noiseless measurements `sum(data{j})=meas{j}.nshots`.
%
%Function handler of the estimator `fun_est` takes the data and
%measurements arrays and the dimenstion array as the input and returns
%density matrix:
%```
%dm = fun_est(data,meas,dim);
%```
%Function handler of the protocol `fun_proto` returns the description of
%the measurements to be performed:
%```
%measurement = fun_proto(jn, ntot, meas, data, dim);
%```
%`jn` - current state sample number, `ntot` - total number of samples,
%`meas` and `data` - measurement array of the measurements performed so far
%and corresponding data array, `dim` - dimension array.
%
%Author: PQCLab, 2020
%Website: https://github.com/PQCLab/QTB
input = inputParser;
addRequired(input, 'fun_est');
addRequired(input, 'fun_proto');
addRequired(input, 'dim');
addOptional(input, 'tests', {});
addParameter(input, 'mtype', 'povm');
addParameter(input, 'name', 'Untitled QT-method');
addParameter(input, 'display', true);
addParameter(input, 'file', 'none');
addParameter(input, 'load', true);
parse(input, fun_est, fun_proto, dim, varargin{:});
opt = input.Results;

if opt.display
    disp('Initialization');
end
result.name = opt.name;
result.dim = opt.dim;
result.lib = "matlab";

% Generate test list
test_desc = qtb_tests(opt.dim);
test_codes = opt.tests;
if isempty(test_codes)
    test_codes = fieldnames(test_desc);
end
loaded = false;
rsave = false;
if ~strcmp(opt.file,'none')
    rsave = true;
    if opt.load && isfile(opt.file)
        rload = load(opt.file,'result');
        rload = rload.result;
        loaded = true;
        fprev = [opt.file, '.asv'];
        save(fprev, '-struct', 'rload');
        if opt.display
            fprintf('Results file loaded. Previous version available as %s\n', fprev);
        end
    end
end

% Prepare tests
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = test_desc.(tcode);
    hash = DataHash(test);
    if loaded && isfield(rload,tcode)
        if strcmp(rload.(tcode).hash, hash)
            result.(tcode) = rload.(tcode);
            continue;
        else
            if opt.display
                fprintf('Failed to load test results for %s: fingerprint mismatch\n', tcode);
            end
        end
    end
    test.hash = hash;
    test.fidelity = nan(test.nexp, length(test.nsample));
    test.nmeas = zeros(test.nexp, length(test.nsample));
    test.time_proto = zeros(test.nexp, length(test.nsample));
    test.time_est = nan(test.nexp, length(test.nsample));
    test.sm_flag = true(test.nexp, 1);
    test.bias = nan(test.nexp, 1);
    result.(tcode) = test;
end

% Perform tests
qrng = qtb_random();
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = result.(tcode);
    if opt.display
        fprintf('===> Running test %d/%d: %s (%s)\n', j_test, length(test_codes), test.name, tcode);
        fprintf('Progress: ');
        h = qtb_print('');
    end
    
    for j_exp = 1:test.nexp
        qrng.seed(test.seed+j_exp);
        dm = qtb_state(test.type, prod(opt.dim), 'rank', test.rank, 'depol', test.depol);
        for j_ntot = 1:length(test.nsample)
            if ~isnan(test.fidelity(j_exp,j_ntot)) % experiment loaded
                continue;
            end
            ntot = test.nsample(j_ntot);
            if opt.display
                h = qtb_print(sprintf('experiment %d/%d, nsamples = 1e%d', j_exp, test.nexp, round(log10(ntot))), h);
            end
            [data,meas,time_proto,sm_flag] = conduct_experiment(dm, ntot, opt.fun_proto, opt.dim, opt.mtype);
            test.time_proto(j_exp,j_ntot) = time_proto;
            test.sm_flag(j_exp) = test.sm_flag(j_exp) && sm_flag;
            
            tic;
            dm_est = qtb_call(opt.fun_est,data,meas,opt.dim);
            test.time_est(j_exp,j_ntot) = toc;
            [f,msg] = qtb_isdm(dm_est);
            if ~f; error('QTB:NotDM', ['Estimator error: ', msg]); end
            
            test.fidelity(j_exp,j_ntot) = qtb_fidelity(dm, dm_est);
            test.nmeas(j_exp,j_ntot) = length(meas);
            result.(tcode) = test;
            if rsave; save(opt.file, 'result'); end
        end
        
        if isnan(test.bias(j_exp))
            if opt.display
                h = qtb_print(sprintf('experiment %d/%d, nsamples -> inf', j_exp, test.nexp), h);
            end
            [data,meas] = conduct_experiment(dm, test.nsample(end)*10, opt.fun_proto, opt.dim, opt.mtype, true);
            dm_est = qtb_call(opt.fun_est, data, meas, opt.dim);
            test.bias(j_exp) = max(0,1-qtb_fidelity(dm,dm_est));
            result.(tcode) = test;
            if rsave; save(opt.file, 'result'); end
        end
    end
    if opt.display
        qtb_print('done\n', h);
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
    jn = 1;
    while jn <= ntot
        tic;
        meas_curr = qtb_call(fun_proto, jn, ntot, meas, data, dim);
        time_proto = time_proto + toc;
        if ~isfield(meas_curr,'nshots')
            meas_curr.nshots = 1;
        end
        if (jn + meas_curr.nshots - 1) > ntot
            error('QTB:NShots', 'Number of measurements exceeds available sample size');
        end
        sm_flag = sm_flag && all(qtb_isprod(meas_curr.(mtype),dim));
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
            if any(prob < -tol)
                error('QTB:ProbNeg', 'Measurement operators are not valid: negative eigenvalues exist');
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
                clicks = qtb_sample(prob, meas_curr.nshots);
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
