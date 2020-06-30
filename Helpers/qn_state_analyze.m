function qn_state_analyze(n, proto_name, est_name, test, varargin)

proto_name = lower(proto_name);
est_name = lower(est_name);
test = lower(test);
dim = repmat(2,1,n);

switch est_name
    case 'ppi'
        est_fun = est_ppi();
        est_mtype = 'povm';
    case 'frls'
        est_fun = est_frls();
        est_mtype = 'povm';
    case 'frml'
        est_fun = est_frml();
        est_mtype = 'povm';
    case 'trml'
        [r, varargin] = qtb_tools.get_field(varargin, 'rank');
        est_fun = est_trml(r);
        est_mtype = 'povm';
    case 'arml'
        [sl, varargin] = qtb_tools.get_field(varargin, 'significanceLevel', 0.05);
        est_fun = est_arml(sl);
        est_mtype = 'povm';
    case 'cs'
        est_fun = est_cs();
        est_mtype = 'observable';
    otherwise
        error('QTB:UnknownEstName', 'Unknown estimator name');
end

switch proto_name
    case 'pauli'
        proto_fun = proto_pauli(n);
        proto_mtype = 'observable';
    case 'mub'
        proto_fun = proto_mub(prod(dim));
        proto_mtype = 'povm';
    case 'fmub'
        proto_fun = proto_fmub(dim);
        proto_mtype = 'povm';
    case 'amub'
        proto_fun = proto_amub(prod(dim), est_fun);
        proto_mtype = 'povm';
    otherwise
        error('QTB:UnknownProtoName', 'Unknown protocol name');
end

% Redefine some estimators after getting protocol type
if strcmp(est_name, 'cs') && strcmp(proto_mtype, 'povm')
    est_fun = est_cs('povm');
    est_mtype = 'povm';
end
    

if ~strcmp(proto_mtype, est_mtype)
    error('QTB:ProtoEstIncompatible', 'Protocol %s and estimator %s are incompatible', upper(proto_name), upper(est_name));
end

[filename, varargin] = qtb_tools.get_field(varargin, 'filename', sprintf('q%d_%s_%s-%s.mat', n, test, proto_name, est_name));
varargin = [varargin, {'filename', filename}];

[name, varargin] = qtb_tools.get_field(varargin, 'name', [upper(proto_name), '-', upper(est_name)]);
varargin = [varargin, {'name', name}];

qtb_analyze(proto_fun, est_fun, dim, test, 'mtype', proto_mtype, varargin{:});

end

