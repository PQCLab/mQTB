function proto = qtb_proto(type, nsub)
%QTB_PROTO Returns measurement protocol of a specific type and number of
%subsystems
%
%   proto = qtb_proto(type) returns measurement protocol of a specific
%   type. `proto{j}` describes the j-th measurement.
%
%   proto = qtb_proto(type, N) returns the factorized measurement protocol
%   of a systems with `N` subsystems.
%
%%Protocol types
%The functions supports following protocol types:
%   • 'pauli_projectors' - proto{j}(:,:,1) and proto{j}(:,:,2) are
%   projectors to j-th Pauli matrix (j = 1,2,3) for a single qubit
%   • 'pauli_observables' - proto{j} is the j-th Pauli observable of a
%   qubit (j = 1,2,3,4; includes identity matrix)
%
%Author: PQCLab, 2020
%Website: https://github.com/PQCLab/QTB
info = struct();
switch type
    case 'pauli'
        mtype = 'observable';
        elems = cell(1,4);
        elems{1} = [1,0;0,1];
        elems{2} = [0,1;1,0];
        elems{3} = [0,-1j;1j,0];
        elems{4} = [1,0;0,-1];
    case {'mub2', 'mub3', 'mub4', 'mub8'}
        mtype = 'povm';
        mub = load('mubs.mat', type);
        mub = mub.(type);
        info.vectors = reshape(num2cell(mub,[1,2]),1,[]);
        elems = cellfun(@(u) qtb_tools.vec2povm(u), info.vectors, 'UniformOutput', false);
    otherwise
        error('QTB:UnknownProto', 'Protocol %s is undefined', type);
end
if nargin > 1 && nsub > 1
    elems = qtb_tools.listkronpower(elems, nsub);
end

proto.mtype = mtype;
proto.elems = elems;
if ~isempty(fieldnames(info))
    proto.info = info;
end

end
