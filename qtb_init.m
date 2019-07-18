function [] = qtb_init(statetype, param)
    function psi = get_state(theta, phi)
        psi = [cos(theta / 2); exp(1i * phi) * sin(theta / 2)];
    end

    function psi = arr2state(s)
        psi = 1;
        s0 = [1; 0];
        s1 = [0; 1];
        s = num2str(s, '%d');
        for i = 1:length(s)
            if (s(i) == '0')
                psi = kron(psi, s0);
            elseif (s(i) == '1')
                psi = kron(psi, s1);
            else
                error(sprintf('QTB Error: Unresolved symbol "%s"!', s(i)));
            end
        end
    end

    global qtb_state;
    
    global qtb_n;
    qtb_n = 0;
    
    global qtb_statistic;
    qtb_statistic.iterations = [];
    qtb_statistic.fidelity = {};
    
    if strcmpi(statetype, 'str')
        qtb_state = arr2state(param);
    elseif strcmpi(statetype, 'pi4')
        qtb_state = get_state(pi / 4, pi / 4);
    elseif strcmpi(statetype, 'bell')
        qtb_state = (arr2state('00') + arr2state('11')) / sqrt(2);
    elseif strcmpi(statetype, 'ghz')
        qtb_state = (arr2state(zeros(1, param)) + arr2state(ones(1, param))) / sqrt(2);
    else
        error('QTB Error: Unknown type of quantum state!')
    end 
end

