# qtb_analyze
Runs the tests to analyze the Quantum Tomography (QT) method.

[**&#8592; Back to contents**](README.md)

## Usage
* `result = qtb_abalyze(fun_proto, fun_est, dim)` performs the all-tests analysis of the QT-method specified by function handlers [fun_proto](#arg-fun_proto) and [fun_est](#arg-fun_est) and dimension array [dim](#arg-dim)
* `result = qtb_abalyze(fun_proto, fun_est, dim, tcode)` specifies the tests to perform by its codename [tcode](#arg-tcode)
* `result = qtb_abalyze(fun_proto, fun_est, dim, tcode, 'file', 'results.mat')` saves intermediate results in the [filename](#arg-filename) (recommended)
* `result = qtb_abalyze( ___ ,Name,Value)` specifies additional arguments using one or more [Name-Value pairs](#args-nv)

## <a name="data-arr">Data array</a>
Data array `data` is a cell array containing measurement results. The content of the _j_-th measurement depends on the QT method measurement type [mtype](#arg-mtype):
* _povm_: `data{j}(k,1)` is the number of observations corresponding to the _k_-th POVM operator of _j_-th measurement,
* _operator_: `data{j}` is the number of observations corresponding to the measurement operator of the _j_-th measurement,
* _observable_: `data{j}` is the observable expectation value in the _j_-th measurement.

## <a name="meas-arr">Measurements array</a>
Measurements array `meas` is a cell array contaning structure arrays of measurements description. The content of the _j_-th measurement depends on the QT method measurement type [mtype](#arg-mtype):
* _povm_: `meas{j}.povm(:,:,k)` is the _k_-th POVM operator of the _j_-th measurement,
* _operator_: `meas{j}.operator` is the measurement operator of the _j_-th measurement,
* _observable_: `meas{j}.observable` is the observable operator of the _j_-th measurement.

Number of _j_-th measurement trials is stored in `meas{j}.nshots`.

The elements of the measurement array may also store auxiliary fields.

## <a name="dim-arr">Dimension array</a>
The dimension array specifies the partition of the Hilbert space.

_**Example:**_ `dim = 2` - single qubit system

_**Example:**_ `dim = [2,2,2]` - three qubits system

_**Example:**_ `dim = [2,3]` - qubit + qutrit system

Note that it is always preferable to specify partition. E.g. use `dim = [2,2]` instead of `dim = 4` for the two-qubit system.

## <a name="args">Input arguments</a>

### <a name="arg-fun_proto">fun_proto</a>
_**Data type:**_ function_handle

Measurement protocol, specified as a function handler. `fun_proto` returns the measurement to be performed. Input arguments are:
* `jn` - the number of samples being measured so far,
* `ntot` - total sample size,
* `meas` - [measurement array](#meas-arr) of the previous measurements,
* `data` - [data array](#data-arr) of the previous measurement results,
* `dim` - [dimension array](#dim-arr).

The function output should be consistent with the [measurements array](#meas-arr) specification.

_**Example:**_ `fun_proto = @povm_protocol_handler`
```matlab
function measurement = povm_protocol_handler(jn,ntot,data,meas,dim)
  % process inputs
  measurement.povm = ...
  measurement.nshots = ...
end
```

One may store additional data in the output structure to use it later in `fun_est` or `fun_proto`.
```matlab
function measurement = povm_protocol_handler(jn,ntot,data,meas,dim)
  % process inputs
  measurement.povm = ...
  measurement.nshots = ...
  measurement.data1 = ...
  measurement.data2 = ...
end
function dm = estimator_handler(data,meas,dim)
  % process measurement results and estimate density matrix dm
  % meas{j}.data1 and meas{j}.data2 are also available
end
```

You may suppress one or more arguments.
```matlab
function measurement = povm_protocol_handler(jn,ntot)
  % process inputs
  measurement.povm = ...
  measurement.nshots = ...
end
```

For the non-adaptive measurement protocols you may use the [static_proto](static_proto.md) helper.

_**Example:**_ `fun_proto = @(jn,ntot) static_proto(jn,ntot,proto)`

Here `proto` is a cell array, which contains measurement operators of type [mtype](#arg-mtype). For example, when `mtype = 'povm'` the [measurements array](#meas-arr) would be defined as `meas{j}.povm = proto.elems{j}` for every _j_. Total sample size is devided equally over all measurements. However, the ratio could be changed. See [static_proto](static_proto.md) documentation for details.

### <a name="arg-fun_est">fun_est</a>
_**Data type:**_ function_handle

Density matrix estimator, specified as a function handler. `fun_est` takes the [measurements](#meas-arr), [data](#data-arr), and [dimension](#dim-arr) arrays as the input and returns density matrix.

_**Example:**_ `fun_est = @estimator_handler`
```matlab
function dm = estimator_handler(data,meas,dim)
  % process measurement results and estimate density matrix dm
end
```

One may suppress the dimension array in your function.
```matlab
function dm = estimator_handler(data,meas)
  % process measurement results and estimate density matrix dm
end
```

One may also specify additional parameters of the estimator using anonymous function.

_**Example:**_ `fun_est = @(data,meas) estimator_handler(data,meas,param1,param2,...)`
```matlab
function dm = estimator_handler(data,meas,param1,param2,...)
  % process measurement results and estimate density matrix dm
end
```

### <a name="arg-dim">dim</a>
_**Data type:**_ double

[Dimension array](#dim-arr).

### <a name="arg-tcode">tcode</a>
_**Data types:**_ char | cell array

Optional test codename or cell array of test codenames (see list of available codenames in [tests specification page](tests_specification.md)). Value `'all'` corresponds to performing all the available tests.

_**Default:**_ `'all'`

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-mtype">mtype</a>
_**Data type:**_ char

Type of the measurements performed by the QT method. Available values: `'povm'`, `'observable'`, `'operator'`. See [measurements array](#meas-arr) section for details.

_**Default:**_ `'povm'`

### name
_**Data type:**_ char

QT method name that would be displayed in reports.

_**Default:**_ `'Untitled QT-method'`

### max_nsample
_**Data type:**_ double

Maximum sample size that the method could handle.

_**Default:**_ `inf`

### display
_**Data type:**_ logical

Display analysis status in the command window.

_**Default:**_ `true`

### <a name="arg-filename">filename</a>
_**Data type:**_ char

Path to file where the analysis results would be stored. If the file already exists the program tries to load existing results and update them. Value `'none'` prevent program from saving results in a file.

**Is is recommended to specify path to file so the long computations could be continued in case of interruption.**

File would contain a single variable `result`, the same as the [function output](#output).

_**Default:**_ `'none'`

### savefreq
_**Data type:**_ double

Frequency of file saving (available when [file](#arg-file) value is set). For example, value `10` makes the program to save results in a file after every 10-th experiment.

The best practice is to set value to `1000` for very fast QT methods as this would make analysis faster. For slow QT methods it is better to set `1`.

_**Default:**_ `1`

## <a name="output">Function output</a>
_**Data type:**_ structure array

Function output `result` is a structure array containing raw analysis results:
* `result.name` - QT method name
* `result.dim` - [dimension array](#dim-arr) specified in the function input
* `result.lib` - analysis library (`'mQTB'` for the current library)
* `result.(tcode)` - results for the test with codename [tcode](#arg-tcode)

For every [tcode](#arg-tcode) specified in the function input `test = result.(tcode)` is a structure array containing raw analysis results for the corresponding test.
* Test description (see [qtb_tests](qtb_tests.md#output)):
  * `test.code` - test code
  * `test.name` - test name
  * `test.seed` - seed for the test random number generator
  * `test.rank` - rank of the density matrices generated within the test
  * `test.nsample(1,k)` - _k_-th value of the total sample size used to test QT method
  * `test.nexp` - number of QT experiments for every value of sample size
  * `test.generator` - generator of the random quantum states
  * `test.hash` - unique test fingerprint
* QT results:
  * `test.fidelity(j,k)` - fidelity between the true and reconstructed (output of [fun_est](#arg-fun_est) handle) density matrices in _j_-th QT experiment for the sample size `test.nsample(1,k)`
  * `test.nmeas(j,k)` - number of measurements (number of [fun_proto](#arg-fun_proto) calls) in _j_-th QT experiment for the sample size `test.nsample(1,k)`
  * `test.time_proto` - total time (in seconds) of protocol computation ([fun_proto](#arg-fun_proto) execution time) in _j_-th QT experiment for the sample size `test.nsample(1,k)`
  * `test.time_est` - time (in seconds) of density matrix estimation ([fun_est](#arg-fun_est) execution time) in _j_-th QT experiment for the sample size `test.nsample(1,k)`
  * `test.sm_flag` - `true` if QT method implies separable measurements only according to [dimension array](#dim-arr), `false` otherwise
