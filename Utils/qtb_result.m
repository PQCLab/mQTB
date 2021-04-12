classdef qtb_result < handle
    
    properties
        name = ''
        dim = []
        cpu = ''
        lib = 'mQTB'
        extension = '.mat'
        filename = ''
        tests = nan
        verbose = true
        data_fields = {'name', 'dim', 'cpu', 'lib'}
    end
    
    methods
        function obj = qtb_result(filename, dim, verbose)
            if nargin > 1
                obj.dim = dim;
            end
            if nargin > 2
                obj.verbose = verbose;
            end
            obj.tests = struct();
            if ~strcmp(filename, 'none')
                el = length(obj.extension);
                if length(filename) <= el || ~strcmpi(filename((end-el+1):end), obj.extension)
                    filename = [filename, obj.extension];
                end
                obj.filename = filename;
            end
        end
        
        function load(obj)
            if isempty(obj.filename) || ~isfile(obj.filename)
                return;
            end
            load(obj.filename, 'data');
            obj.set_data(data);
            if obj.verbose
                disp('Results file loaded with tests:');
                fields = fieldnames(obj.tests);
                for j = 1:length(fields)
                    fprintf('* %s (%s)\n', obj.tests.(fields{j}).name, obj.tests.(fields{j}).code);
                end
            end
        end
        
        function save(obj)
            if ~isempty(obj.filename)
                data = obj.get_data();
                save(obj.filename, 'data');
            end
        end
        
        function set_dim(obj, dim)
            obj.dim = dim;
        end
        
        function set_name(obj, name)
            obj.name = name;
        end
        
        function set_cpu(obj, cpu)
            if nargin < 2
                if ~exist('cpuinfo','file')
                    return;
                end
                cpu = cpuinfo();
                cpu = cpu.Name;
            end
            obj.cpu = cpu;
        end
        
        function set_data(obj, data)
            if ~isempty(obj.dim) && ~isequal(data.dim, obj.dim)
                error('QTB:DimMismatch', 'Failed to set data: dimensions mismatch');
            end
            for j = 1:length(obj.data_fields)
                obj.(obj.data_fields{j}) = data.(obj.data_fields{j});
            end
            fields = fieldnames(data);
            for j = 1:length(fields)
                if ~any(ismember(obj.data_fields, fields{j}))
                    tcode = fields{j};
                    obj.tests.(tcode) = data.(tcode);
                end
            end
        end
        
        function data = get_data(obj)
            data = struct();
            for j = 1:length(obj.data_fields)
                data.(obj.data_fields{j}) = obj.(obj.data_fields{j});
            end
            fields = fieldnames(obj.tests);
            for j = 1:length(fields)
                tcode = fields{j};
                data.(tcode) = obj.tests.(tcode);
            end
        end
        
        function init_test(obj, test)
            thash = DataHash(test);
            new_test = true;
            tcode = test.code;
            if isfield(obj.tests, tcode)
                if strcmp(obj.tests.(tcode).hash, thash)
                    new_test = false;
                else
                    if obj.verbose
                        warning('off','backtrace');
                        warning('QTB:TestFingerprintMismatch', 'Failed to update results for test %s (fingerprint mismatch).\nThese results will be overwritten\n', test.code);
                        warning('on','backtrace');
                    end
                end
            end
            
            if new_test
                testr = test;
                testr.hash = thash;
                testr.time_proto = zeros(test.nexp, length(test.nsample));
                testr.time_est = nan(test.nexp, length(test.nsample));
                testr.nmeas = zeros(test.nexp, length(test.nsample));
                testr.fidelity = nan(test.nexp, length(test.nsample));
                testr.sm_flag = true;
                obj.tests.(tcode) = testr;
            end
        end
        
        function exps = experiments(obj, tcode)
            test = obj.tests.(tcode);
            exps = {};
            for exp_id = 1:test.nexp
                exps{end+1} = struct(...
                    'exp_num', exp_id,...
                    'time_est', test.time_est(exp_id, :),...
                    'time_proto', test.time_proto(exp_id, :),...
                    'nmeas', test.nmeas(exp_id, :),...
                    'fidelity', test.fidelity(exp_id, :),...
                    'sm_flag', test.sm_flag,...
                    'is_last', false...
                );
            end
            exps{end}.is_last = true;
        end
        
        function update(obj, tcode, exp_id, experiment)
            fields = {'time_est', 'time_proto', 'nmeas', 'fidelity'};
            for j = 1:length(fields)
                obj.tests.(tcode).(fields{j})(exp_id,:) = experiment.(fields{j});
            end
            obj.tests.(tcode).sm_flag = obj.tests.(tcode).sm_flag && experiment.sm_flag;
        end
        
    end
end

