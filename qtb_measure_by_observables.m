function [result] = qtb_measure_by_observables(obs)
    if (length(size(obs)) > 2)
        result = zeros(1, size(obs, 3));
        for i = 1:size(obs, 3)
            result(i) = qtb_measure_by_observables(obs(:, :, i));
        end
        return
    end
    
    global qtb_state qtb_n;
    qtb_n = qtb_n + 1;

    [U, D] = eig(obs);
    d = diag(D);
    n = length(obs);
    probs = zeros(1, n);
    for i = 1:n
        psi = U(:, i);
        probs(i) = abs(psi' * qtb_state)^2;
    end
    probs = cumsum(probs);
    p = rand;
    result = d(end);
    for i = 1:n
        if (p < probs(i))
            result = d(i);
            break
        end
    end
end

