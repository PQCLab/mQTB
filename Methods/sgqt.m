classdef sgqt
methods (Static)

function fun_proto = proto()
    fun_proto = iterative_proto(@sgqt.proto_handler);
end

function measset = proto_handler(niter, jn, ntot, meas, data, dim)
    N = 2*100;
    Dim = prod(dim);
    [alp,bet] = sgqt.params(niter);
    delta = sgqt.rand_delta(Dim);

    if niter == 1
        psi = zeros(Dim,1);
        psi(1) = 1;
    else
        grad = (data{end-1}/meas{end-1}.nshots - data{end}/meas{end}.nshots)/(2*bet);
        psi = meas{end}.psi + alp*grad*meas{end}.delta;
        psi = psi / sqrt(psi'*psi);
    end

    if ntot-jn < N
        N = ntot-jn;
    end

    measset = cell(1,2);
    measset{1} = sgqt.get_meas(psi, bet, delta, floor(N/2));
    measset{2} = sgqt.get_meas(psi,-bet, delta, ceil(N/2));
end

function fun_est = estimator()
    fun_est = @sgqt.estimator_handler;
end

function dm = estimator_handler(meas, data)
    niter = meas{end}.iter;
    [alp,bet] = sgqt.params(niter);
    grad = (data{end-1}/meas{end-1}.nshots - data{end}/meas{end}.nshots)/(2*bet);
    psi = meas{end}.psi + alp*grad*meas{end}.delta;
    psi = psi / sqrt(psi'*psi);
    dm = psi*psi';
end

function del = rand_delta(Dim)
    del = 2*((rand(Dim,1)>0.5)-1) + 1j*2*((rand(Dim,1)>0.5)-1);
end

function measurement = get_meas(psi, coeff, delta, nshots)
    psip = psi + coeff*delta;
    psip = psip / sqrt(psip'*psip);
    measurement.operator = psip*psip';
    measurement.nshots = nshots;
    measurement.psi = psi;
    measurement.delta = delta;
end

function [alp, bet] = params(niter)
    A = 0;
    a = 3;
    b = 0.1;
    s = 0.602;
    t = 0.101;
    alp = a/(niter+1+A)^s;
    bet = b/(niter+1)^t;
end

end
end
