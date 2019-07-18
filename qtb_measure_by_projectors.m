function [result] = qtb_measure_by_projectors(proj)
    if (length(size(proj)) > 2)
        result = zeros(1, size(proj, 3));
        for i = 1:size(proj, 3)
            result(i) = qtb_measure_by_projectors(proj(:, :, i));
        end
        return
    end

    global qtb_state qtb_n;
    qtb_n = qtb_n + 1;
    
    prob = real(qtb_state' * proj * qtb_state);
    if (rand < prob)
        result = 1;
    else
        result = 0;
    end
end

