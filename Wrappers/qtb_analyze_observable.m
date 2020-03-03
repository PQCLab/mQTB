function result = qtb_analyze_observable(fun_est_obs, fun_proto_obs, dim, varargin)

result = qtb_analyze(...
    @(data,meas,dim) fun_est(fun_est_obs,data,meas,dim),...
    @(j,n,meas,data,dim) fun_proto(fun_proto_obs,j,n,meas,data,dim),...
    dim, varargin{:});

end

function dm = fun_est(fun_est_obs,data,meas,dim)
    dm = qtb_call(fun_est_obs,prepare_data(data,meas),meas,dim);
end

function meas_curr = fun_proto(fun_proto_obs,j,n,meas,data,dim)
    meas_curr = qtb_call(fun_proto_obs,j,n,meas,prepare_data(data,meas),dim);
    [meas_curr.povm, meas_curr.eigvals] = qtb_obs2povm(meas_curr.observable);
end

function data = prepare_data(data,meas)
    data = cellfun(@(k,m) sum(k.*m.eigvals)/sum(k), data, meas);
end