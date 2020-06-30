function tests = qtb_tests(dim)
%QTB_TESTS Returns the list of all the available tests.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_tests.md
%Author: Boris Bantysh, 2020
nsub = length(dim);
Dim = prod(dim);

tests.rps.code = 'RPS';
tests.rps.name = 'Random pure states';
tests.rps.seed = 161;
tests.rps.nsample = 10.^([2,3,4,5,6] + max(0,nsub-3));
tests.rps.nexp = 1000;
tests.rps.rank = 1;
tests.rps.generator = {'haar_dm', 'rank', 1};

tests.rmspt_2.code = 'RMSPT-2';
tests.rmspt_2.name = 'Random mixed states by partial tracing: rank-2';
tests.rmspt_2.seed = 1312;
tests.rmspt_2.nsample = 10.^([2,3,4,5,6] + max(0,nsub-2));
tests.rmspt_2.nexp = 1000;
tests.rmspt_2.rank = 2;
tests.rmspt_2.generator = {'haar_dm', 'rank', 2};

tests.rmspt_d.code = 'RMSPT-d';
tests.rmspt_d.name = 'Random mixed states by partial tracing: rank-d';
tests.rmspt_d.seed = 117218;
tests.rmspt_d.nsample = 10.^([2,3,4,5,6] + (nsub-1));
tests.rmspt_d.nexp = 1000;
tests.rmspt_d.rank = Dim;
tests.rmspt_d.generator = {'haar_dm', 'rank', Dim};

tests.rnp.code = 'RNP';
tests.rnp.name = 'Random noisy preparation';
tests.rnp.seed = 758942;
tests.rnp.nsample = 10.^([2,3,4,5,6] + (nsub-1));
tests.rnp.nexp = 1000;
tests.rnp.rank = Dim;
tests.rnp.generator = {'haar_dm', 'rank', 1, 'init_err', {'unirnd', 0, 0.05}, 'depol', {'unirnd', 0, 0.01}};

end
