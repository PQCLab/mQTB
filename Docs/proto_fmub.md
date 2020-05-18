# proto_fmub
Generates protocol handler for factorized mutually unbiased bases measurements. The protocol is the tensor product of independent mutually unbiased bases for each subsystem. Note that for the single subsystem case the protocol coincides with [proto_mub](proto_mub.md).

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_proto = proto_fmub(dim)` - generates protocol handler for a dimension array [dim](#arg-dim)

## <a name="args">Input arguments</a>

### <a name="arg-dim">dim</a>
_**Data type:**_ vector

[Dimension array](qtb_analyze.md#dim-arr). Each element of the array sets the dimension of a subsystem.

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Protocol handler](qtb_analyze.md#arg-fun_proto).
