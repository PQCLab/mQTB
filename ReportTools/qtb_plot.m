function [h_plot, h_patch, h_out] = qtb_plot(x,y,varargin)

input = inputParser;
addRequired(input, 'x');
addRequired(input, 'y');
addOptional(input, 'mode', 'stats', @(x) any(validatestring(x,{'stats','scatter','area'})));
addParameter(input, 'DisplayName', '');
addParameter(input, 'Color', 1);
addParameter(input, 'LineStyle', '-');
addParameter(input, 'showOuts', true);
addParameter(input, 'outlierMethod', 'quartiles');
addParameter(input, 'quantile', 0.95);
addParameter(input, 'scatterSize', 10);
parse(input, x, y, varargin{:});
opt = input.Results;

if length(opt.Color) == 1
    opt.Color = get_color(opt.Color);
end

switch opt.mode
    case 'stats'
        switch opt.outlierMethod
            case 'quartiles'
                outYlog = isoutlier(y,'quartiles',2);
            case 'quantile'
                yup = quantile(y, opt.quantile, 2);
                outYlog = y > repmat(yup,1,size(y,2));
            otherwise
                error('QTB:OutsMethod', 'Unknown outliers method');
        end
        [minY, maxY, meanY, quartYtop, quartYbot] = deal(zeros(1,length(x)));
        for i = 1:length(x)
            inY = y(i,~outYlog(i,:));
            minY(i) = min(inY);
            maxY(i) = max(inY);
            meanY(i) = mean(inY);
            quartYtop(i) = quantile(inY, 0.75);
            quartYbot(i) = quantile(inY, 0.25);
        end
        xd = repmat(x(:), 1, size(y,2));
        outN = xd(outYlog);
        outY = y(outYlog);

        h_patch = patch([x,fliplr(x)], [maxY, fliplr(minY)], opt.Color, 'FaceAlpha', 0.25, 'LineStyle', 'none', 'HandleVisibility', 'off');
        hold on;
        h_plot = errorbar(x, meanY, meanY-quartYbot, quartYtop-meanY, 'LineStyle', opt.LineStyle, 'Color', opt.Color, 'LineWidth', 1.5, 'MarkerSize', 10, 'DisplayName', opt.DisplayName);
        if opt.showOuts
            h_out = scatter(outN,outY,opt.scatterSize,'filled','MarkerFaceColor',opt.Color,'MarkerEdgeColor','none','HandleVisibility', 'off');
        end
    case 'scatter'
        x = repmat(x',1,size(y,2));
        h_plot = scatter(x(:),y(:),opt.scatterSize,'filled','MarkerFaceColor',opt.Color,'MarkerEdgeColor','none', 'DisplayName', opt.DisplayName);
    case 'area'
        ymin = min(y,[],2);
        ymax = max(y,[],2);
        h_plot = patch([x(:);flipud(x(:))], [ymax; flipud(ymin)], opt.Color, 'FaceAlpha', 0.25, 'LineStyle', 'none', 'DisplayName', opt.DisplayName);
    otherwise
        error('QTB:PlotMode', 'Unknown plot mode');
end

end

function c = get_color(n)
cmp = get(gca,'ColorOrder');
c = cmp(n,:);
end