# est_frls
Full rank least squares estimator by POVM measurements results. Density matrix is estimated by minimization of least squares between theoretical and experimental probabilities. To satisfy density matrix positivity the minimization is done by convex optimization with positivity constraint.

[**&#8592; Back to contents**](README.md)

## Usage
* `dm = est_frls(meas,data,dim)` returns density matrix by POVM measurement results

## <a name="args">Input arguments</a>

### <a name="arg-dim">meas</a>
_**Data type:**_ cell array

[Measurements array](qtb_analyze.md#meas-arr).

### <a name="arg-dim">data</a>
_**Data type:**_ cell array

[Data array](#data-arr).

### <a name="arg-dim">dim</a>
_**Data type:**_ vector

[Dimension array](qtb_analyze.md#dim-arr).

## <a name="output">Function output</a>
_**Data type:**_ matrix

Density matrix.
