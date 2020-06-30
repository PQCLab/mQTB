# Quantum Tomography Benchmarking

MATLAB library for benchmarking quantum tomography (QT) methods. Full documentation is available [**here**](Docs/README.md).

## Getting Started

### Prerequisites and installing

The library was tasted on MATLAB R2018b. Required toolboxes and external libraries:
* MATLAB Statistics toolbox
* [DataHash](https://www.mathworks.com/matlabcentral/fileexchange/31272-datahash) library

To install the library clone the repository or download and unpack zip-archive. Before using run the startup script.

```
>> qtb_startup
```

Some of the implemented QT methods require installing external MATLAB libraries:
* est_ppi - https://github.com/qMLE/qMLE
* est_frls - http://cvxr.com/cvx/
* est_frml - https://github.com/PQCLab/RootTomography
* est_trml - https://github.com/PQCLab/RootTomography
* est_arml -https://github.com/PQCLab/RootTomography
* est_cs - http://cvxr.com/cvx/

### Analyze the method benchmarks

The following code shows a basic example of running analysis for a 2-qubit tomography method on random pure states.
``` matlab
dim = [2,2];
result = qtb_analyze(proto_fmub(dim), est_ppi(), dim, 'rps');
```

The following code calculates benchmarks using raw data obtained above.
``` matlab
report = qtb_report(result, 'rps');
disp(report.table);
```
