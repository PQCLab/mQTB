function [result] = qtb_measure_by_states(psi, n)  
    n_states = size(psi, 2);

    if (nargin == 1)
        global qtb_state qtb_n;      
        qtb_n = qtb_n + n_states;
             
        probs = (abs(transpose(psi) * qtb_state).^2)';
        r = rand(1, n_states);
        result = r < probs; 
    else
        result = qtb_measure_by_states(repmat(psi, 1, n));
        result = reshape(result, n_states, round(length(result) / n_states))';
        result = sum(result, 1);
    end
end

