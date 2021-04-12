function report = qtb_report(result, tcode, varargin)
%QTB_REPORT Reports benchmarks of the QT method based on qtb_analyze raw output.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_report.md
%Author: Boris Bantysh, 2020
input = inputParser;
addRequired(input, 'result');
addRequired(input, 'tcode');
addParameter(input, 'percentile', 95);
addParameter(input, 'error_rates', [1e-1,1e-2,1e-3,1e-4]);
addParameter(input, 'plot', false);
addParameter(input, 'export', 'none');
parse(input, result, tcode, varargin{:});
opt = input.Results;

if ischar(result)
    result = qtb_result(result, [], false);
    result.load();
end

if ~isfield(result.tests, tcode)
    error('QTB:NoResults', 'No results for test `%s`', tcode);
end
test = result.tests.(tcode);

report.name = result.name;
report.dim = result.dim;
report.tcode = tcode;
report.tname = test.name;
report.percentile = opt.percentile;
report.error_rates = opt.error_rates;

quant = opt.percentile/100;
errs = opt.error_rates;
logn = log10(double(test.nsample));

Nexp = size(test.fidelity,1);
ind = find(all(~isnan(test.fidelity),2));
if length(ind) < Nexp
    warning('QTB:EmptyResults', 'Statistics is incomplete: %d/%d results are empty', Nexp-length(ind), Nexp);
    Nexp = length(ind);
end

r = test.rank;

df_perc = quantile(1-test.fidelity(ind,:), quant, 1);
df_mean = mean(1-test.fidelity(ind,:), 1);
nmeas_perc = quantile(test.nmeas(ind,:), quant, 1);
tproto_perc = quantile(test.time_proto(ind,:), quant, 1);
test_pec = quantile(test.time_est(ind,:), quant, 1);
aboxes = qtb_stats.awhiskerbox(1-test.fidelity(ind,:),1);

config = qtb_config();
report.fields = config.TableFields;
report.data = zeros(length(errs), config.TableFieldsNum);
data_str = cell(length(errs), config.TableFieldsNum);
for j = 1:length(errs)
    data_row = nan(1,config.TableFieldsNum);
    data_row_str = cell(1,config.TableFieldsNum);
    data_row_str(:) = {'-'};
    if all(df_perc > errs(j)) || all(df_perc < errs(j)) % linear extrapolation
        lognb = interp1(df_perc, logn, errs(j), 'linear', 'extrap');
        data_row(1) = round(10^lognb);
        data_row_str{1} = ['*', qtb_tools.num2str(data_row(1))];
    else
        lognb = interp1(log10(df_perc),logn,log10(errs(j)));
        data_row(1) = round(10^lognb);
        data_row(2) = round(interp1(logn,nmeas_perc,lognb));
        data_row(3) = interp1(logn,tproto_perc,lognb);
        data_row(4) = interp1(logn,test_pec,lognb);
        data_row(5) = qtb_stats.get_bound(data_row(1),report.dim,r,'mean')/(10^interp1(logn,log10(df_mean),lognb));
        data_row(6) = interp1(logn,sum(aboxes.isout,1)/Nexp,lognb);
        data_row_str(1:6) = arrayfun(@qtb_tools.num2str, data_row(1:6), 'UniformOutput', false);
    end
    data_row(7) = all(test.sm_flag);
    if data_row(7); data_row_str{7} = 'Y'; else; data_row_str{7} = 'N'; end
    
    report.data(j,:) = data_row;
    data_str(j,:) = data_row_str;
end

data_cols = mat2cell(data_str, length(errs), ones(1,config.TableFieldsNum));
report.table = table(data_cols{:}, 'VariableNames', report.fields,...
    'RowNames', arrayfun(@(e) [num2str((1-e)*100),'%'], errs, 'UniformOutput', false));

if opt.plot
    report.figure = figure;
    dim = strjoin(arrayfun(@num2str,report.dim,'UniformOutput',false),char(215));
    %sgtitle([test.name, ' (dim = ', dim,')']);

    subplot(2,2,1);
    grid on; hold on;
    qtb_plot(test.nsample,1-test.fidelity);
    set(gca,{'XScale','YScale'},{'log','log'});
    xlabel('Sample size');
    ylabel('Infidelity');

    subplot(2,2,2);
    grid on; hold on;
    qtb_plot(test.nsample,test.nmeas,'Color',2);
    set(gca,'XScale','log');
    xlabel('Sample size');
    ylabel('Measurement number');

    subplot(2,2,3);
    grid on; hold on;
    qtb_plot(test.nsample,test.time_proto,'Color',2);
    set(gca,'XScale','log');
    xlabel('Sample size');
    ylabel('Protocol computation time, s');

    subplot(2,2,4);
    grid on; hold on;
    qtb_plot(test.nsample,test.time_est,'Color',2);
    set(gca,'XScale','log');
    xlabel('Sample size');
    ylabel('State estimation time, s');
end

if ~strcmpi(opt.export, 'none')
    formats = {'.xls','.xlsx','.csv'};
    [~,~,ext] = fileparts(opt.export);
    if any(strcmp(ext,formats))
        writetable(report.table, opt.export, 'WriteRowNames', true);
    else
        warning('QTB:WrongFormat', 'Failed to save file. The following formats are available: %s,', strjoin(formats,', '));
    end
end

end

