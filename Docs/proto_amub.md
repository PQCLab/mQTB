# proto_mub
Generates adaptive protocol handler for mutually unbiased bases measurements. At every adaptive step the handler performs state estimation using acquired data and rotates the bases to set on of them along the principle component of the state.

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_proto = proto_fmub(d, fun_est)` - generates protocol handler for dimension [d](#arg-d) and estimator, specified as a function handler [fun_est](#fun_est)

## <a name="args">Input arguments</a>

### <a name="arg-d">d</a>
_**Data type:**_ integer

Hilbert space dimension.

### <a name="arg-fun_est">fun_est</a>
_**Data type:**_ function_handle

[Estimator handler](qtb_analyze.md#arg-fun_est) that runs at every adaptive state to estimate current density matrix.

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Protocol handler](qtb_analyze.md#arg-fun_proto).
