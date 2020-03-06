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
disp('Initialization');
input = inputParser;
addRequired(input, 'fun_est');
addRequired(input, 'fun_proto');
addRequired(input, 'dim');
addOptional(input, 'tests', {});
addParameter(input, 'name', 'Untitled QT-method');
addParameter(input, 'file', '');
addParameter(input, 'load', true);
parse(input, fun_est, fun_proto, dim, varargin{:});
opt = input.Results;

result.dim = opt.dim;
result.name = opt.name;

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
        fprintf('Results file loaded. Previous version available as %s\n', fprev);
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
            fprintf('Failed to load test results for %s: fingerprint mismatch\n', tcode);
        end
    end
    rng(test.seed);
    test.hash = hash;
    test.fidelity = nan(test.nexp, length(test.nsample));
    test.nmeas = zeros(test.nexp, length(test.nsample));
    test.time_proto = zeros(test.nexp, length(test.nsample));
    test.time_est = nan(test.nexp, length(test.nsample));
    test.bias = nan(test.nexp, 1);
    result.(tcode) = test;
end

% Perform tests
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    test = result.(tcode);
    fprintf('===> Running test %d/%d: %s (%s)\n', j_test, length(test_codes), test.name, tcode);
    fprintf('Progress: ');
    h = qtb_print('');
    
    for j_exp = 1:test.nexp
        rng(test.seed+j_exp);
        dm = qtb_state(test.type, prod(opt.dim), 'rank', test.rank, 'depol', test.depol);
        for j_ntot = 1:length(test.nsample)
            if ~isnan(test.fidelity(j_exp,j_ntot)) % experiment loaded
                continue;
            end
            ntot = test.nsample(j_ntot);
            h = qtb_print(sprintf('experiment %d/%d, nsample = 1e%d', j_exp, test.nexp, round(log10(ntot))), h);
            tic;
            [data,meas] = conduct_experiment(dm,ntot,opt);
            test.time_proto(j_exp,j_ntot) = toc;
            tic;
            dm_est = qtb_call(opt.fun_est,data,meas,opt.dim);
            test.time_est(j_exp,j_ntot) = toc;
            test.fidelity(j_exp,j_ntot) = qtb_fidelity(dm, dm_est);
            test.nmeas(j_exp,j_ntot) = length(meas);
            test.dm_est{j_exp,j_ntot} = dm_est;
            result.(tcode) = test;
            if rsave
                save(opt.file, 'result');
            end
        end
        
        h = qtb_print(sprintf('experiment %d/%d, asymptotic', j_exp, test.nexp), h);
        if isnan(test.bias(j_exp))
            [data,meas] = conduct_experiment(dm,test.nsample(end)*10,opt,true);
            dm_est = qtb_call(opt.fun_est,data,meas,opt.dim);
            test.bias(j_exp) = max(0,1-qtb_fidelity(dm,dm_est));
            result.(tcode) = test;
            if rsave
                save(opt.file, 'result');
            end
        end
    end
    qtb_print('done\n', h);
end

fprintf('All tests are finished!\n\n');

end

function [data,meas] = conduct_experiment(dm,ntot,opt,asymp)
    if nargin < 4
        asymp = false;
    end

    data = {};
    meas = {};
    jn = 1;
    while jn <= ntot
        meas_curr = qtb_call(opt.fun_proto, jn, ntot, meas, data, opt.dim);
        if ~isfield(meas_curr,'nshots')
            meas_curr.nshots = 1;
        end
        if (jn + meas_curr.nshots - 1) > ntot
            error('Number of measurements exceeds available sample size');
        end
        prob = zeros(size(meas_curr.povm,3),1);
        for k = 1:size(meas_curr.povm,3)
            prob(k) = real(trace(dm*meas_curr.povm(:,:,k)));
        end
        prob = prob/sum(prob);
        if asymp
            clicks = prob*meas_curr.nshots;
        else
            clicks = qtb_sample(prob/sum(prob), meas_curr.nshots);
        end
        data{end+1} = clicks;
        meas{end+1} = meas_curr;
        jn = jn + meas_curr.nshots;
    end
end
