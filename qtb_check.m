function [] = qtb_check(psi)
    global qtb_state qtb_n qtb_statistic;
    
    F = abs(psi' * qtb_state)^2;
    
    index = find(qtb_statistic.iterations == qtb_n);
    if isempty(index)
        qtb_statistic.iterations = [qtb_statistic.iterations, qtb_n];
        qtb_statistic.fidelity{end + 1} = F;
    else
        qtb_statistic.fidelity{index} = [qtb_statistic.fidelity{index}, F];
    end
end

