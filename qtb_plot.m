function [] = qtb_plot()
    global qtb_statistic;
    
    std_line_width = 1;
    line_width = 2;
    font_size = 12;
    filling_alpha = 0.1;
    color = 'b';
    
    iters = qtb_statistic.iterations;
    n = length(iters);
    
    len = cellfun(@length, qtb_statistic.fidelity);
    
    figure();
       
    if any(len > 1)        
        fids = zeros(1, n);
        stds = zeros(1, n);
        for i = 1:n
            fids(i) = mean(qtb_statistic.fidelity{i});
            stds(i) = std(qtb_statistic.fidelity{i});
        end
        
        err_top = fids + stds;
        err_bottom = fids - stds;       
        x2 = [iters, fliplr(iters)];
        area = [err_top, fliplr(err_bottom)];
        
        hold on;
        plot(iters, err_top, color, 'LineWidth', std_line_width);
        plot(iters, err_bottom, color, 'LineWidth', std_line_width);
        h = fill(x2, area, color);
        set(h, 'FaceAlpha', filling_alpha);
        set(h, 'EdgeColor', 'None');
    else
        fids = cell2mat(qtb_statistic.fidelity);
    end

    plot(iters, fids, color, 'LineWidth', line_width); 
    xlabel('Number of iterations');
    ylabel('Fidelity');
    xlim(minmax(iters));
    y = get(gca, 'YLim');
    ylim([y(1), 1]);
    set(gca, 'FontSize', font_size);
    hold off;
    grid on;
    box on;
end

