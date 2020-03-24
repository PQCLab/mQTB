dir = fileparts(mfilename('fullpath'));
addpath(genpath([dir,'\Methods']));
addpath(genpath([dir,'\Libs']));
addpath(genpath([dir,'\Utils']));
addpath(genpath([dir,'\Helpers']));
fprintf('All paths are set. Library is ready to use.\n');
fprintf('For documentation see functions help and library page <a href="https://github.com/PQCLab/QTB">https://github.com/PQCLab/QTB</a>.\n');