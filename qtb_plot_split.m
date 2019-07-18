function [] = qtb_plot_split()
    global qtb_statistic;

    line_width = 2;
    font_size = 12;
    
    iters = qtb_statistic.iterations;
    n = length(iters);
    
    len = cellfun(@length, qtb_statistic.fidelity);
    minval = min(len);
    
    figure();
      
    hold on;
    for i = 1:minval
        fids = zeros(1, n);
        for j = 1:n
            fids(j) = qtb_statistic.fidelity{j}(i);
        end
        plot(iters, fids, 'LineWidth', line_width);
    end
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

