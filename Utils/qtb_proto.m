function proto = qtb_proto(type, N)
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
switch type
    case 'pauli_projectors'
        proto = cell(1,3);
        proto{1}(:,:,1) = [1 1; 1 1]/2;
        proto{1}(:,:,2) = [1 -1; -1 1]/2;
        proto{2}(:,:,1) = [1 -1j; 1j 1]/2;
        proto{2}(:,:,2) = [1 1j; -1j 1]/2;
        proto{3}(:,:,1) = [1 0; 0 0];
        proto{3}(:,:,2) = [0 0; 0 1];
    case 'pauli_observables'
        proto = cell(1,4);
        proto{1} = [1,0;0,1];
        proto{2} = [0,1;1,0];
        proto{3} = [0,-1j;1j,0];
        proto{4} = [1,0;0,-1];
    otherwise
        error('Protocol %s is undefined', type);
end

if nargin > 1 && N > 1
    proto = qtb_proto_product(proto,N);
end

end
