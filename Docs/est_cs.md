# est_cs
Compressed sensing estimator by Pauli observable measurements results. Density matrix is estimated by simultaneous minimization of density matrix trace and least squares between theoretical and experimental probabilities. To satisfy density matrix positivity the minimization is done by convex optimization with positivity constraint. After the minimization density matrix is renormalized.

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_est = est_frls()` generates estimator handler
* `fun_est = est_frls(mtype)` specifies measurements type

## <a name="args">Input arguments</a>

### <a name="arg-mtype">mtype</a>
_**Data type:**_ char

[Measurements type](qtb_analyze.md#mtype).

_**Default:**_ `'observable'`

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Estimator handler](qtb_analyze.md#arg-fun_est).
