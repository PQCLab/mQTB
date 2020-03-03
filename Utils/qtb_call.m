function varargout = qtb_call(fun,varargin)
%QTB_CALL Calls the function handler
%
%Author: PQCLab, 2020
%Website: https://github.com/PQCLab/QTB
n = nargin(fun);
if n < 0
    n = length(varargin);
end

varargout = cell(1,nargout);
[varargout{:}] = fun(varargin{1:n});

end

