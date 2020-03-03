function dm = sgqt_estimator(data,meas,dim)

sgqt_params;
k = meas{end}.iter;
bet = b/(k+1)^t;
alp = a/(k+1+A)^s;
grad = (data{end-1}(1)/sum(data{end-1})-data{end}(1)/sum(data{end}))/(2*bet);
psi = meas{end}.psi + alp*grad*meas{end}.delta;
psi = psi / sqrt(psi'*psi);
dm = psi*psi';

end

