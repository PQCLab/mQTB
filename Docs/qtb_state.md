# qtb_state
Generates random quantum state of a given type. Detailed information about the state generation is given in the [tests specification](tests_specification.md) page.

[**&#8592; Back to contents**](README.md)

## Usage
* `x = qtb_state(dim,type)` returns random vector state or density matrix of a specific [type](#arg-type) and dimension array [dim](#arg-dim)
* `x = qtb_state( ___ ,Name,Value)` specifies additional arguments using one or more [Name-Value pairs](#args-nv)

## <a name="args">Input arguments</a>

### <a name="arg-dim">dim</a>
_**Data type:**_ double

[Dimension array](qtb_analyze.md#dim-arr).

### <a name="arg-type">type</a>
_**Data type:**_ char

Quantum state type. Available values:
* `haar_vec` - [Haar random vector state](tests_specification.md#haar_vec)
* `haar_dm` - [Haar random density matrix](tests_specification.md#haar_dm) (rank ![r](https://latex.codecogs.com/svg.latex?r) is set by [rank](#arg-rank) argument)
* `bures` - [Bures random density matrix](tests_specification.md#bures)

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-rank">rank</a>
_**Data type:**_ double

The dimension of a latent space for the `'haar_dm'` quantum state [type](#arg-type).

_**Default:**_ `prod(dim)`

### <a name="arg-init_err">init_err</a>
_**Data type:**_ cell array

[Parameter generator](#pargen) for the system [initialization error](tests_specification.md#init_err).

_**Default:**_ `{}`

### <a name="arg-depol">depol</a>
_**Data type:**_ cell array

[Parameter generator](#pargen) for the [depolarization noise](tests_specification.md#depol).

_**Default:**_ `{}`

## <a name="output">Function output</a>
_**Data type:**_ matrix

Vector state or density matrix.

## <a name="pargen">Parameter generator</a>

Parameter generator is a cell array `{ptype, x1, x2}` that specifies a parameter value of a chosen type:
* `ptype='fixed'` - parameter value is equal to `x1`
* `ptype='unirnd'` - parameter value is generated randomly according to uniform distribution from `x1` to `x2`
* `ptype='normrnd'` - parameter value is generated randomly according to normal distribution with mean `x1` and standard deviation `x2`
