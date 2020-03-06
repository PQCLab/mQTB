# Quantum Tomography Benchmarking

MATLAB library for benchmarking quantum tomography (QT) methods. **Detailed documentation is under development.**

## Getting Started

### Prerequisites and installing

The library was tasted on MATLAB R2018b. Required toolboxes and external libraries:
* Statistics toolbox

To install the library clone the repository or download and unpack zip-archive. Before using run the startup script.

```
>> qtb_startup
```

Some of the estimators require installing external MATLAB libraries:
* apg_estimator - https://github.com/qMLE/qMLE
* cgls_estimator - https://github.com/qMLE/qMLE
* convopt_estimator - http://cvxr.com/cvx/
* compsens_estimator - http://cvxr.com/cvx/
* root_estimator - https://github.com/PQCLab/RootTomography

### Analyze the method resources

The following code shows the basic example of running analysis for a 2-qubit tomography method:

```
proto = qtb_proto('pauli_projectors', 2); % Generate measurement protocol for 2-qubit state tomography
qtb_analyze(...
    @ppinv_estimator,... % Specify estimator handler
    @(j,n) static_proto(j,n,proto),... % Specify protocol handler
    [2,2], {}, 'name', 'Projected pseudo-inversion', 'file', 'result.mat');
```

To report the analysis results one should use the qtb_report function:

```
report = qtb_report('result.mat');
disp(['=======> Test result: ', report.rps.name]);
disp(report.rps.resources);
disp(['=======> Test result: ', report.drps.name]);
disp(report.drps.resources);
```