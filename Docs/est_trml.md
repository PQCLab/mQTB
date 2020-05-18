# est_trml
True rank maximum likelihood estimator estimator by POVM measurements results. Density matrix is estimated by maximization of likelihood function. The maximization is done by numerical solving of likelihood equation for the square root of a density matrix with a fixed rank equal to the true rank of estimated state.

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_est = est_trml(r)` - generates estimator handler for quantum state rank [r](#arg-r)

## <a name="args">Input arguments</a>

### <a name="arg-r">r</a>
_**Data type:**_ integer

True quantum state rank.

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Estimator handler](qtb_analyze.md#arg-fun_est).
