function dm = sgqt_estimator(data,meas,dim)

sgqt_params;
k = meas{end}.iter;
bet = b/(k+1)^t;
alp = a/(k+1+A)^s;
grad = (data{end-1}/meas{end-1}.nshots - data{end}/meas{end}.nshots)/(2*bet);
psi = meas{end}.psi + alp*grad*meas{end}.delta;
psi = psi / sqrt(psi'*psi);
dm = psi*psi';

end

