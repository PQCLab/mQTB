# qtb_debug
Runs a single quantum tomography (QT) and returns complete information.

[**&#8592; Back to contents**](README.md)

## Usage
* `info = qtb_debug(fun_proto, fun_est, dim, ntot, tcode)` performs a single run of a QT method specified by function handlers [fun_proto](#arg-fun_proto) and [fun_est](#arg-fun_est) and dimension array [dim](#arg-dim). Total sample size is set by [ntot](#arg-ntot). The random state is generated according to the test with codename [tcode](#arg-tcode).
* `info = qtb_debug(fun_proto, fun_est, dim, ntot, 'dm', dm)` specifies a particular input density matrix [dm](#arg-dm).
* `info = qtb_debug( ___ ,Name,Value)` specifies additional arguments using one or more [Name-Value pairs](#args-nv).

## <a name="args">Input arguments</a>

### <a name="arg-fun_proto">fun_proto</a>
_**Data type:**_ function_handle

[Protocol handler](qtb_analyze.md#arg-fun_proto).

### <a name="arg-fun_est">fun_est</a>
_**Data type:**_ function_handle

[Estimator handler](qtb_analyze.md#arg-fun_est).

### <a name="arg-dim">dim</a>
_**Data type:**_ vector

[Dimension array](qtb_analyze.md#dim-arr).

### <a name="arg-ntot">ntot</a>
_**Data type:**_ integer

Total measurements sample size. By setting `inf` one gets asymptotic values of measurements results.

### <a name="arg-tcode">tcode</a>
_**Data type:**_ char

Codename of a test that is used to generate a random input density matrix (see list of available codenames in [tests specification page](tests_specification.md)). If the value is set to `'none'` function takes [dm](#arg-dm) as the input density matrix.

_**Default:**_ `'none'`

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-tcode">dm</a>
_**Data type:**_ matrix

Input density matrix of a QT-method. The field could be used only if [tcode](#arg-tcode) is set to `'none'`.

_**Default:**_ `'none'`

### <a name="arg-mtype">mtype</a>
_**Data type:**_ char

Type of the measurements performed by the QT method. Available values: `'povm'`, `'observable'`, `'operator'`. See [measurements array](qtb_analyze.md#meas-arr) section for details.

_**Default:**_ `'povm'`

## <a name="output">Function output</a>
_**Data type:**_ structure array

Function output `info` is a structure array containing information about the QT-method run:
* `info.options` - function inputs
* `info.asymp` - `true` if asymptotic measurements results were used in simulation, `false` otherwise
* `info.dm` - input density matrix for the QT method
* `info.meas` - [measurements array](qtb_analyze.md#meas-arr)
* `info.data` - [data array](qtb_analyze.md#data-arr)
* `info.nmeas` - number of measurements (length of measurements array)
* `info.sm_flag` - `true` if QT method implies separable measurements only according to [dimension array](#arg-dim), `false` otherwise
* `info.time_proto` - total time (in seconds) of protocol computation ([fun_proto](#arg-fun_proto) execution time)
* `info.time_est` - time (in seconds) of density matrix estimation ([fun_est](#arg-fun_est) execution time)
* `info.dm_est` - density matrix estimation ([fun_est](#arg-fun_est) execution result)
* `info.fidelity` - fidelity between density matrices `info.dm` and `info.dm_est`
