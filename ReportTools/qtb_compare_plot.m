function figs = qtb_compare_plot(result1, result2, tests)

if ischar(result1)
    load(result1,'result');
    result1 = result;
end
if ischar(result2)
    load(result2,'result');
    result2 = result;
end

if nargin < 3
    tests = {};
end

test_codes = fieldnames(result1.tests);
figs = cell(1,length(test_codes));
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    if ~isempty(tests) && ~any(strcmp(tests,tcode))
        continue;
    end
    test1 = result1.tests.(tcode);
    test2 = result2.tests.(tcode);
    figs{j_test} = figure;
    grid on;
    test1.fidelity(test1.fidelity>1) = (1+(1-test1.fidelity(test1.fidelity>1))); % TODO: remove
    test2.fidelity(test2.fidelity>1) = (1+(1-test2.fidelity(test2.fidelity>1))); % TODO: remove
    qtb_plot(test1.nsample,1-qtb_join_data(test1.fidelity), 'Color', 1, 'DisplayName', result1.name);
    qtb_plot(test2.nsample,1-qtb_join_data(test2.fidelity), 'Color', 2, 'DisplayName', result2.name);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    dim = strjoin(arrayfun(@num2str,result1.dim,'UniformOutput',false),char(215));
    title([test1.name, ' (dim = ', dim,')']);
    xlabel('N samples');
    ylabel('Infidelity');
    legend('show');
end

end

