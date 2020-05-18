# qtb_proto
Generates a measurement protocol. The output could be used as [static_proto](static_proto.md) input argument.

[**&#8592; Back to contents**](README.md)

## Usage
* `proto = qtb_proto(type)` returns the measurement protocol of a specified [type](#arg-type)
* `proto = qtb_proto(type,nsub)` specifies the number of subsystems [nsub](#arg-nsub) with identical independent measurements

## <a name="args">Input arguments</a>

### <a name="arg-type">type</a>
_**Data type:**_ char

Type of the measurement protocol. Available values:
* `'mub2'`
* `'mub3'`
* `'mub4'`
* `'mub8'`
* `'pauli'`.

MUBs are the measurements in mutually unbiased bases.

_**Example:**_ `qtb_proto('mub4')` generates protocol with POVM operators corresponding to the MUB measurements in 4-dimensional system.

`'pauli'` is the measurement protocol in 2-dimensional system based on the measurement of Pauli observables. The first element is identity matrix and the other 3 elements are _x_, _y_ and _z_ Pauli matrices in standard representation.

### <a name="arg-nsub">nsub</a>
_**Data type:**_ double

Number of subsystems. If the value `nsub > 1` the protocol is the `nsub`-th tensor power of a single-system protocol.

_**Example:**_ `qtb_proto('mub2', 3)` generates protocol with POVM operators corresponding to factorized 3-qubit measurements (each qubit is measured independetly using 1-qubit MUB).

_**Default:**_ `1`

## <a name="output">Function output</a>
_**Data type:**_ structure array

Output array `proto` describes the measurement protocol:
* `proto.mtype` - measurements type
* `proto.elems` - cell array of protocol elements

Let `Mj = proto.elems{j}` be the _j_-th protocol element. For POVM measurements `proto.mtype = 'povm'` and matrix `Mj(:,:,k)` corresponds to _k_-th POVM operator. For observable measurements `proto.mtype = 'observable'` and `Mj` is the observable matrix. For operator measurements `proto.mtype = 'operator'` and `Mj` is the measurement operator matrix.
