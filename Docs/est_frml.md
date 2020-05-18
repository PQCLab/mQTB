# est_frml
Full rank maximum likelihood estimator estimator by POVM measurements results. Density matrix is estimated by maximization of likelihood function. The maximization is done by numerical solving of likelihood equation for the square root of a density matrix.

[**&#8592; Back to contents**](README.md)

## Usage
* `dm = est_frml(meas,data)` returns density matrix by POVM measurement results

## <a name="args">Input arguments</a>

### <a name="arg-dim">meas</a>
_**Data type:**_ cell array

[Measurements array](qtb_analyze.md#meas-arr).

### <a name="arg-dim">data</a>
_**Data type:**_ cell array

[Data array](#data-arr).

## <a name="output">Function output</a>
_**Data type:**_ matrix

Density matrix.
