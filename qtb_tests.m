function tests = qtb_tests(dim)
%QTB_TESTS Returns the tests descriptors for a specific system dimenstion
%
%   tests = qtb_tests(dim) - returns tests descriptors for a specific
%   dimension array
%
%OUTPUT:
%   tests.(tcode) - test descritor for a tests `tcode`
%
%Author: PQCLab, 2020
%Website: https://github.com/PQCLab/QTB
N = length(dim);
Dim = prod(dim);

tests.rps.name = 'Random pure states';
tests.rps.seed = 161;
tests.rps.nsample = 10.^[2,3,4,5,6] * 10^max(0,N-3);
tests.rps.type = 'random';
tests.rps.nexp = 1000;
tests.rps.rank = 1;
tests.rps.depol = nan;

tests.drps.name = 'Depolarized random pure states';
tests.drps.seed = 1312;
tests.drps.nsample = 10.^[2,3,4,5,6] * 10^(N-1);
tests.drps.type = 'random';
tests.drps.nexp = 1000;
tests.drps.rank = 1;
tests.drps.depol = [0,0.1];

end

