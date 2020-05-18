if ~exist('DataHash','file')
    throwAsCaller(MException('QTB:NoDataHash', 'Function DataHash not found\nDownload it from <a href="https://www.mathworks.com/matlabcentral/fileexchange/31272-datahash">https://www.mathworks.com/matlabcentral/fileexchange/31272-datahash</a> and include it to search path'));
end
dir = fileparts(mfilename('fullpath'));
addpath(dir);
addpath(genpath([dir,'\Methods']));
addpath(genpath([dir,'\Utils']));
addpath(genpath([dir,'\Helpers']));
fprintf('All paths are set. Library is ready to use.\n');
fprintf('Documentation is available at <a href="https://github.com/PQCLab/mQTB">https://github.com/PQCLab/mQTB</a>.\n');
fprintf('See Examples directory for examples of library usage.\n');