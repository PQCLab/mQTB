function report = qtb_report(result, varargin)
%QTB_REPORT Generates a report of an analysis result
%
%   report = qtb_report(result) returns the report of an analysis result
%   obtained by `qtb_report` function
%
%   report = qtb_report(result, T) returns the report for a desired test
%   codes `T`
%
%   report = qtb_report( ___ ,Name,Value)  specifies line properties using
%   one or more Name,Value pair arguments. Available arguments:
%       • Quantile (float) - specifies the quantile for analysis. Default:
%       0.95.
%       • Export (string) - specifies the export format. Available formats:
%       'html'. Default: 'none'.
%       • File (string) - filename to export report. Default: 'none'.
%       • Plot (boolean) - plot analysis result. Default: false.
%
%Author: PQCLab, 2020
%Website: https://github.com/PQCLab/QTB
input = inputParser;
addRequired(input, 'result');
addOptional(input, 'tests', {});
addParameter(input, 'quantile', 0.95);
addParameter(input, 'export', 'none');
addParameter(input, 'file', 'none');
addParameter(input, 'plot', false);
parse(input, result, varargin{:});
opt = input.Results;

fnames = {'F = 90%';'F = 99%';'F = 99.9%';'F = 99.99%'};
zs = [1,2,3,4];
le_sign = char(8804);
ge_sign = char(8805);

if ischar(result)
    load(result,'result');
end

if isempty(opt.tests)
    test_desc = qtb_tests(result.dim);
    test_codes = fieldnames(test_desc);
else
    test_codes = opt.tests;
end

report.name = result.name;
report.dim = result.dim;
report.quantile = opt.quantile;
for j_test = 1:length(test_codes)
    tcode = test_codes{j_test};
    if ~isfield(result,tcode)
        continue;
    end
    
    test = result.(tcode);   
    report.(tcode).name = test.name;
    
    dfid = 1-qtb_join_data(test.fidelity);
    nmeas = qtb_join_data(test.nmeas);
    time_proto = qtb_join_data(test.time_proto);
    time_est = qtb_join_data(test.time_est);
    
    n = test.nsample;
    
    fidbias = mean(test.bias);
    
    res_num = get_resources(n,dfid,fidbias,zs,nmeas,time_proto,time_est,opt.quantile);
    res_text = cell(length(zs),4);
    for j1 = 1:size(res_text,1)
        for j2 = 1:size(res_text,2)
            rn = res_num(j1,j2);
            if isnan(rn)
                res_text{j1,j2} = '-';
            elseif rn == 0
                res_text{j1,j2} = [le_sign, qtb_num2str(min(n))];
            elseif isinf(rn)
                res_text{j1,j2} = [ge_sign, qtb_num2str(max(n))];
            else
                res_text{j1,j2} = qtb_num2str(rn);
            end
        end
    end
    
    report.(tcode).resources_num = res_num;
    report.(tcode).resources = table(res_text(:,1),res_text(:,2),res_text(:,3),res_text(:,4),...
        'VariableNames', {'NSamples','Measurements','ProtocolTime','EstimationTime'},...
        'RowNames', fnames);

    outsr = zeros(1,length(test.dms));
    for j_state = 1:length(test.dms)
        fids = permute(test.fidelity(j_state,:,:),[2,3,1]);
        outs = isoutlier(fids,'quartiles',2);
        outsr(j_state) = sum(outs,'all')/numel(outs);
    end
    report.(tcode).outliers = mean(outsr);
    report.(tcode).bias = fidbias;
    
    if opt.plot
        report.(tcode).figure = figure;
        dim = strjoin(arrayfun(@num2str,report.dim,'UniformOutput',false),char(215));
        sgtitle([test.name, ' (dim = ', dim,')']);

        subplot(2,2,1);
        grid on; hold on;
        qtb_plot(n,dfid);
        set(gca,{'XScale','YScale'},{'log','log'});
        xlabel('Sample size');
        ylabel('Infidelity');

        subplot(2,2,2);
        grid on; hold on;
        qtb_plot(n,nmeas,'Color',2);
        set(gca,'XScale','log');
        xlabel('Sample size');
        ylabel('Measurement number');

        subplot(2,2,3);
        grid on; hold on;
        qtb_plot(n,time_proto,'Color',2);
        set(gca,'XScale','log');
        xlabel('Sample size');
        ylabel('Protocol computation time (sec)');

        subplot(2,2,4);
        grid on; hold on;
        qtb_plot(n,time_est,'Color',2);
        set(gca,'XScale','log');
        xlabel('Sample size');
        ylabel('State estimation time (sec)');
    end
end

dir = [fileparts(mfilename('fullpath')),'\Templates\'];
switch opt.export
    case 'html'
        tpl_test_page = fileread([dir,'html_test_page.tpl']);
        tpl_test_table = fileread([dir,'html_test_table.tpl']);
        tpl_test_table_row = fileread([dir,'html_test_table_row.tpl']);
        le_text = '&le;';
        ge_text = '&ge;';
        dash_text = '&ndash;';
    otherwise
        return;
end

test_codes = fieldnames(report.tests);
data_tables = cell(1,length(test_codes));
for j = 1:length(test_codes)
    tcode = test_codes{j};
    test = report.(tcode);
    data_rows = cell(1,length(fnames));
    for k = 1:length(fnames)
        data_rows{k} = replace(tpl_test_table_row,...
            {'%%fidelity%%','%%nsample%%','%%meas_num%%','%%time_proto%%','%%time_est%%'},...
            [fnames(k),test.resources{k,:}]);
        data_rows{k} = replace(data_rows{k}, {le_sign,ge_sign,'-'}, {le_text,ge_text,dash_text});
    end
    data_tables{j} = replace(tpl_test_table,...
        {'%%test_name%%', '%%quantile%%', '%%data_rows%%', '%%fidbias%%', '%%outliers%%'},...
        {test.name, [qtb_num2str((1-opt.quantile)*100),'%'], strjoin(data_rows,'\n'), [qtb_num2str(test.bias*100),'%'], [qtb_num2str(test.outliers*100),'%']});
end
data_page = replace(tpl_test_page, {'%%method%%', '%%data_tables%%'}, {report.name, strjoin(data_tables,'\n')});
dfid = fopen(opt.file, 'wt');
fprintf(dfid, '%s\n', data_page);
fclose(dfid);

end

function resources = get_resources(n,df,fidbias,zs,nmeas,time_proto,time_est,quant)
    df = quantile(df, quant, 2);
    nmeas = quantile(nmeas, quant, 2);
    time_proto = quantile(time_proto, quant, 2);
    time_est = quantile(time_est, quant, 2);

    logn = log10(n);
    z = -log10(df);
    zbias = -log10(fidbias);
    resources = nan(length(zs),4);
    for j = 1:length(zs)
        lognz = interp1(z,logn,zs(j));
        nz = round(10^lognz);
        if isnan(nz)
            if all(z > zs(j))
                resources(j,1) = 0; % 0 is for <=min(n)
            elseif all(zbias > zs(j))
                resources(j,1) = inf; % inf is for >=max(n)
            end
        else
            resources(j,1) = nz;
            resources(j,2) = interp1(logn,nmeas,lognz);
            resources(j,3) = interp1(logn,time_proto,lognz);
            resources(j,4) = interp1(logn,time_est,lognz);
        end
    end
end
