clc;
clear;
rng(1234);

dim = [2,2,2];
Dim = prod(dim);
dm = qtb_state('random', Dim, 'Rank', 1);

% Niter = 25;
% jmeas = 0;
% data = {};
% meas = {};
% nall1 = [];
% fid1 = [];
% dmrec = zeros(Dim,Dim);
% dmrec(1,1) = 1;
% for iter = 1:Niter
%     disp(iter);
%     phis = mat2cell(randn(Dim,Dim+1) + 1j*randn(Dim,Dim+1), Dim, ones(1,Dim+1));
%     proto = cellfun(@(c) vectors2povm(complement_basis(c/norm(c))), phis, 'UniformOutput', false);
%     if iter > 1
%         dmrec = apg_est(meas,data,dmrec);
%         [psi,~] = eig(dmrec);
%         proto{1} = vectors2povm(psi);
%     end
%     nshots = max(100, floor(jmeas/30));
%     measset = cellfun(@(povm) struct('povm',povm,'nshots',nshots), proto, 'UniformOutput', false);
%     for jm = 1:length(measset)
%         prob = zeros(Dim,1);
%         for km = 1:size(measset{jm}.povm,3)
%             prob(km) = real(trace(dm*measset{jm}.povm(:,:,km)));
%         end
%         data{end+1} = qtb_sample(prob/sum(prob), nshots);
%         meas{end+1} = measset{jm};
%         jmeas = jmeas + nshots;
%         nall1(end+1) = jmeas;
%         dmrec = apg_est(meas,data,dmrec);
%         fid1(end+1) = qtb_fidelity(dm,dmrec);
%     end
% end

Niter = 200;
jmeas = 0;
data = {};
meas = {};
nall2 = [];
fid2 = [];
dmrec = zeros(Dim,Dim);
dmrec(1,1) = 1;
for iter = 1:Niter
    disp(iter);
    
    [U,D] = eig(dmrec);
    [~,ind] = sort(diag(D),'descend');
    K = randi(sum(dim)-length(dim));
    psis = U(:,ind(1:K));
    phis = get_suborth(psis,dim);
    u = 1;
    for j_phi = 1:length(phis)
        u = kron(u, complement_basis(phis{j_phi}));
    end
    povm = vectors2povm(u);
    nshots = max(100, floor(jmeas/30));
    prob = zeros(Dim,1);
    for km = 1:size(povm,3)
        prob(km) = real(trace(dm*povm(:,:,km)));
    end
    data{end+1} = qtb_sample(prob/sum(prob), nshots);
    meas{end+1} = struct('povm',povm,'nshots',nshots);
    jmeas = jmeas + nshots;
    nall2(end+1) = jmeas;
    dmrec = apg_est(meas,data,dmrec);
    fid2(end+1) = qtb_fidelity(dm,dmrec);
end

%%
% nall3 = 10.^[2,3,4,5,6];
% fid3 = [];
% proto = qtb_proto('pauli_projectors',length(dim));
% for j = 1:length(nall3)
%     nshots = rt_nshots_devide(nall3(j),length(proto));
%     clicks = rt_simulate(dm,proto,nshots);
%     dmrec = rt_dm_reconstruct(clicks,proto,nshots,'rank','auto');
%     fid3(end+1) = qtb_fidelity(dm,dmrec);
% end

%%
figure; hold on; grid on;
plot(nall1,1-fid1,'DisplayName','Eigen');
plot(nall2,1-fid2,'DisplayName','FO');
plot(nall3,1-fid3,'DisplayName','Static');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
legend('show');

%%
tic;apg_est(meas,data,dmrec);toc;tic;apg_est(meas,data,'pinv');toc;
function dm = apg_est(meas,data,dm0)
proto = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
dm = rt_dm_reconstruct(data,proto,'init',dm0);

% operators = cellfun(@(m) m.povm, meas, 'UniformOutput', false);
% operators = cat(3, operators{:});
% f = cellfun(@(fj) fj(:), data, 'UniformOutput', false);
% f = vertcat(f{:});
% opts.rho0 = dm0;
% try
%     dm = qse_apg(operators, f, opts);
% catch
%     opts.rho0 = opts.rho0*(1-1e-7) + eye(size(dm0,1))/size(dm0,1)*1e-7;
%     dm = qse_apg(operators, f, opts);
% end
end