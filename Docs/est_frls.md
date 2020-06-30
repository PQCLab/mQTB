# est_frls
Full rank least squares estimator by POVM measurements results. Density matrix is estimated by minimization of least squares between theoretical and experimental probabilities. To satisfy density matrix positivity the minimization is done by convex optimization with positivity constraint.

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_est = est_frls()` generates estimator handler

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Estimator handler](qtb_analyze.md#arg-fun_est).
