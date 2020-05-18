function [hb, hw, ho] = qtb_plot(x,y,varargin)

input = inputParser;
addRequired(input, 'x');
addRequired(input, 'y');
addOptional(input, 'dim', 1);
addParameter(input, 'name', '');
addParameter(input, 'color', 1);
addParameter(input, 'style', '-');
addParameter(input, 'show_whiskers', true);
addParameter(input, 'show_outs', true);
addParameter(input, 'outs_size', 8);
parse(input, x, y, varargin{:});
opt = input.Results;

if length(opt.color) == 1
    opt.color = qtb_tools.get_member(opt.color,get(gca,'ColorOrder'),1);
end

if opt.dim == 2
    y = y';
end
x = reshape(x,1,[]);
xlen = length(x);
if size(y,2) ~= xlen
    error('QTB:PlotDim', 'Arrays dimensions mismatch');
end

abox = qtb_stats.awhiskerbox(y, 1);
if opt.show_whiskers
    [ymin,ymax] = deal(zeros(1,xlen));
    for j = 1:xlen
        yin = y(~abox.isout(:,j),j);
        ymin(j) = min(yin);
        ymax(j) = max(yin);
    end
    hw = patch([x,fliplr(x)], [ymax, fliplr(ymin)], opt.color, 'FaceAlpha', 0.2, 'LineStyle', 'none', 'HandleVisibility', 'off');
    hold on;
end

hb = errorbar(x, abox.med, abox.med-abox.q25, abox.q75-abox.med, 'LineStyle', opt.style, 'Color', opt.color, 'LineWidth', 1.5, 'MarkerSize', 10, 'DisplayName', opt.name);
hold on;

if opt.show_outs
    xscat = repmat(x,size(y,1),1);
    xscat = xscat(abox.isout);
    yscat = y(abox.isout);
    ho = scatter(xscat,yscat,opt.outs_size,'filled','MarkerFaceColor',opt.color,'MarkerEdgeColor','none','HandleVisibility', 'off');
end

end
