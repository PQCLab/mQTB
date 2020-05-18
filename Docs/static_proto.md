# static_proto
Generates [protocol handler](qtb_analyze.md#arg-fun_proto) for static (non-adaptive) protocols.

[**&#8592; Back to contents**](README.md)

## Usage
* `fun_proto = static_proto(proto)` generates protocol handler for static protocol [proto](#arg-proto")

## <a name="args">Input arguments</a>

### <a name="arg-proto">proto</a>
_**Data type:**_ structure array

Protocol description. The array should have the following fields:
* `proto.mtype` - [measurement type](qtb_analyze.md#arg-mtype)
* `proto.elems` - elements of the protocol
* `proto.ratio` - array of ratios between number of samples for every protocol element (optional)

Number of protocol elements is the number of diffent measurements that should be performed. Suppose `Mj = proto.elems{j}` is the _j_-th measurement. For `'povm'` measurement type `Mj(:,:,k)` is the _k_-th POVM operator matrix. For `'observable'` measurement type `Mj` is the observable operator matrix. For `'operator'` measurement type `Mj` is the measurement operator matrix.

By default the total sample size [ntot](#arg-ntot) is devided equally over all protocol elements. One can adjust samples size partition by setting `proto.ratio` array. Then the _j_-th protocol element is used `ntot*proto.ratio(j)/sum(proto.ratio)` times.

## <a name="output">Function output</a>
_**Data type:**_ function_handle

[Protocol handler](qtb_analyze.md#arg-fun_proto).
