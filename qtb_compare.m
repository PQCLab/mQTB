function report = qtb_compare(results, tcode, varargin)
%QTB_COMPARE Compares benchmarks of QT methods based on qtb_analyze raw 
%outputs. The results are sorted according to the sample size benchmark.
%Documentation: https://github.com/PQCLab/mQTB/blob/master/Docs/qtb_compare.md
%Author: Boris Bantysh, 2020
input = inputParser;
addRequired(input, 'results');
addRequired(input, 'tcode');
addParameter(input, 'names', {});
addParameter(input, 'error_rate', 1e-3);
addParameter(input, 'plot', 'none');
addParameter(input, 'percentile', 95);
addParameter(input, 'bound', true);
addParameter(input, 'export', 'none');
parse(input, results, tcode, varargin{:});
opt = input.Results;

results = reshape(results, [], 1);
for j = 1:length(results)
    result = results{j};
    if ischar(result)
        if ~isfile(result)
            warning('QTB:NoFile', 'File `%s` not found', result);
            results{j} = struct();
            continue;
        end
        load(result,'result');
    end
    if ~isfield(result,tcode)
        results{j} = struct();
        continue;
    end
    if ~isempty(opt.names)
        result.name = opt.names{j};
    end
    result.j = j;
    results{j} = result;
end
isemp = cellfun(@(c) isempty(fieldnames(c)), results);
results(isemp) = [];

dim = results{1}.dim;
Tests = qtb_tests(dim);
r = Tests.(tcode).rank;
nsample = Tests.(tcode).nsample;

t = qtb_tools;
makeplt = ~strcmp(opt.plot,'none');
if makeplt
    report.figure = figure('DefaultAxesFontSize', 12);
    hold on; grid on;
    if opt.bound
        switch opt.plot
            case 'percentile'
                dfp = qtb_stats.get_bound(nsample, dim, r, 'percentile', opt.percentile);
                plot(nsample, dfp, '-.', 'Color', [0,0,0], 'LineWidth', 1.2, 'DisplayName', 'Lower bound');
            case 'stats'
                df25 = qtb_stats.get_bound(nsample, dim, r, 'percentile', 25);
                dfmed = qtb_stats.get_bound(nsample, dim, r, 'percentile', 50);
                df75 = qtb_stats.get_bound(nsample, dim, r, 'percentile', 75);
                errorbar(nsample, dfmed, dfmed-df25, df75-dfmed, '-.', 'Color', [0,0,0], 'LineWidth', 1.2, 'DisplayName', 'Lower bound');
            case 'mean'
                dfmean = qtb_stats.get_bound(nsample, dim, r, 'mean');
                plot(nsample, dfmean, '-.', 'Color', [0,0,0], 'LineWidth', 1.2, 'DisplayName', 'Lower bound');
        end
    end
    cmp = get(gca,'ColorOrder');
    lst = {'-','--','-x','-.','-o',':'};
end
config = qtb_config();
report.fields = config.TableFields;
report.names = cellfun(@(c) c.name, results, 'UniformOutput', false);
report.data = zeros(length(results), config.TableFieldsNum);
data_str = cell(length(results), config.TableFieldsNum);
for j = 1:length(results)
    result = results{j};
    name = result.name;
    test = result.(tcode);
    
    Nexp = size(test.fidelity,1);
    ind = find(all(~isnan(test.fidelity),2));
    if length(ind) < Nexp
        warning('QTB:EmptyResults', 'Statistics on `%s` is incomplete: %d/%d results are empty', name, Nexp-length(ind), Nexp);
        test.fidelity = test.fidelity(ind,:);
    end
    
    if ~isnan(opt.error_rate)
        rep = qtb_report(result, tcode, 'percentile', opt.percentile, 'error_rates', opt.error_rate);
        report.data(j,:) = rep.data;
        data_str(j,:) = rep.table{1,:};
    end
    
    if makeplt
        clr = t.get_member(result.j,cmp,1);
        stl = t.get_member(result.j,lst);
        switch opt.plot
            case 'percentile'
                dfp = quantile(1-test.fidelity, opt.percentile/100, 1);
                plot(test.nsample, dfp, stl, 'Color', clr, 'LineWidth', 1.5, 'DisplayName', name);
            case 'stats'
                qtb_plot(test.nsample, 1-test.fidelity, 'Color', clr, 'DisplayName', name);
            case 'mean'
                dfmean = mean(1-test.fidelity, 1);
                plot(test.nsample, dfmean, stl, 'Color', clr, 'LineWidth', 1.5, 'DisplayName', name);
        end
    end
end

[~,ind] = sort(report.data(:,1));
report.names = report.names(ind);
report.data = report.data(ind,:);
data_str = data_str(ind,:);

if opt.bound && ~isnan(opt.error_rate)
    report.names = [{'Lower bound'}; report.names];
    
    data_row = nan(1,config.TableFieldsNum);
    data_row_str = cell(1,config.TableFieldsNum);
    data_row_str(:) = {'-'};
    
    n = 10.^(0:ceil( log10(max(nsample))+2 ));
    dfp = qtb_stats.get_bound(n, dim, r, 'percentile', opt.percentile);
    data_row(1) = round(10^(interp1(log10(dfp),log10(n),log10(opt.error_rate))));
    data_row(5) = 1;
    report.data = [data_row; report.data];
    
    data_row_str{1} = qtb_tools.num2str(data_row(1));
    data_row_str{5} = '1';
    data_str = [data_row_str; data_str];
end

data_cols = mat2cell(data_str, size(data_str,1), ones(1,config.TableFieldsNum));
report.table = table(data_cols{:}, 'VariableNames', report.fields, 'RowNames', report.names);

if makeplt
    if ~isnan(opt.error_rate)
        plot(nsample, repmat(opt.error_rate, size(nsample)), '--', 'Color', [0,0,0], 'LineWidth', 1.2, 'DisplayName', 'Benchmark level');
    end
    set(gca, 'Xscale', 'log');
    set(gca, 'Yscale', 'log');
    xlabel('$$N$$', 'Interpreter', 'latex');
    switch opt.plot
        case 'percentile'
            ylabel(['$$\left[1-F\right]_{',num2str(opt.percentile),'}$$'], 'Interpreter', 'latex');
        case 'stats'
            ylabel('$$1-F$$', 'Interpreter', 'latex');
        case 'mean'
            ylabel('$$\left<1-F\right>$$', 'Interpreter', 'latex');
    end
    legend('show','Location','southwest','FontSize',10);
    pos = get(gcf, 'Position');
    set(gcf, 'Position', [pos(1),pos(2),pos(4)*1.1,pos(4)]);
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


