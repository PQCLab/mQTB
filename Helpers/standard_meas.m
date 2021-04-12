function data = standard_meas(dm, meas)

tol = 1e-8;
elem = meas.elem;
switch meas.mtype
    case 'povm'
        m = size(elem, 3);
        prob = zeros(m,1);
        for k = 1:m
            prob(k) = abs(trace(dm * elem(:,:,k)));
        end
        extraop = false;
        probsum = sum(prob);
        if any(prob < 0)
            if any(prob < -tol)
                error('QTB:ProbNeg', 'Measurement operators are not valid: negative eigenvalues exist');
            end
            prob(prob < 0) = 0;
            probsum = sum(prob);
        end
        if probsum > 1+tol
            error('QTB:ProbGT1', 'Measurement operators are not valid: total probability is greater than 1');
        end
        if probsum < 1-tol
            extraop = true;
            prob = [prob; 1-probsum];
        end
        clicks = qtb_stats.sample(prob, meas.nshots);
        if extraop
            clicks = clicks(1:(end-1));
        end
        data = clicks;
    case 'operator'
        meas.mtype =  'povm';
        clicks = standard_meas(dm, meas);
        data = clicks(1);
    case 'observable'
        [eigb, eigv] = eig(elem);
        meas.elem = zeros(size(eigb,1), size(eigb,1), size(eigb,2));
        for jb = 1:size(eigb, 2)
            meas.elem(:,:,jb) = eigb(:,jb) * eigb(:,jb)';
        end
        meas.mtype = 'povm';
        clicks = standard_meas(dm, meas);
        data = clicks' * diag(eigv) / meas.nshots;
    otherwise
        error('QTB:UnknownMeasType', 'Unknown measurement type `%s`', meas.mtype);
end

end

