function measset = sgqt_proto(k,j,n,meas,data,dim)

sgqt_params;
n_iter = min(n/4,20000);
dim = prod(dim);
delta = delta_fun(dim);
bet = b/(k+1)^t;
alp = a/(k+1+A)^s;

if k == 1
    psi = zeros(dim,1);
    psi(1) = 1;
else
    grad = (data{end-1}/meas{end-1}.nshots - data{end}/meas{end}.nshots)/(2*bet);
    psi = meas{end}.psi + alp*grad*meas{end}.delta;
    psi = psi / sqrt(psi'*psi);
end

if n-j+1 < n_iter
    n_iter = n-j+1;
end

measset = cell(1,2);
measset{1} = get_meas(psi, bet, delta, floor(n_iter/2));
measset{2} = get_meas(psi,-bet, delta, ceil(n_iter/2));

end

function measurement = get_meas(psi,coeff,delta,n)
psip = psi + coeff*delta;
psip = psip / sqrt(psip'*psip);
measurement.operator(:,:,1) = psip*psip';
measurement.nshots = n;
measurement.psi = psi;
measurement.delta = delta;
end

