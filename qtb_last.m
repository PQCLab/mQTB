function [F] = qtb_last()
    global qtb_statistic;
    F = qtb_statistic.fidelity{end};
end

