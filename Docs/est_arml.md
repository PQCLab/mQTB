# est_arml
Adequate rank maximum likelihood estimator estimator by POVM measurements results. Density matrix is estimated by maximization of likelihood function. The maximization is done by numerical solving of likelihood equation for the square root of a density matrix. Quantum state rank is chosen automatically by means of chi-squared test.

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_est = est_arml()` generates estimator handler
* `fun_est = est_arml(sl)` specifies significance level

## <a name="args">Input arguments</a>

### <a name="arg-sl">sl</a>
_**Data type:**_ double

Significance level for a chi-squared test.

_**Default:**_ `0.05`

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Estimator handler](qtb_analyze.md#arg-fun_est).
