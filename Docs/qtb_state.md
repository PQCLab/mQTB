# qtb_state
Generates random quantum state of a given type.

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
* `haar_vec` - [Haar random vector state](#haar_vec)
* `haar_dm` - [Haar random density matrix](#haar_dm) (rank ![r](https://latex.codecogs.com/svg.latex?r) is set by [rank](#arg-rank) argument)
* `bures` - [Bures random density matrix](#bures)

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-rank">rank</a>
_**Data type:**_ double

The dimension of a latent space for the `'haar_dm'` quantum state [type](#arg-type).

_**Default:**_ `prod(dim)`

### <a name="arg-init_err">init_err</a>
_**Data type:**_ cell array

Parameter generator for the system initialization error

_**Default:**_ `{}`

### <a name="arg-depol">depol</a>
_**Data type:**_ cell array

Parameter generator for the depolarization noise

_**Default:**_ `{}`

## <a name="output">Function output</a>
_**Data type:**_ double

Vector state or density matrix.

## Types of random quantum states

Below we consider diffent types of random quantum states in a ![d](https://latex.codecogs.com/svg.latex?d)-dimensional Hilbert space. Some of them are induced by the Haar measure on the unitary group ![U(d)](https://latex.codecogs.com/svg.latex?U(d)). A random unitary matrix ![U](https://latex.codecogs.com/svg.latex?U) according to this measure has the form [[1](#ref1)]

![U=Q\Lambda](https://latex.codecogs.com/svg.latex?U=Q\Lambda), &nbsp; &nbsp; ![\Lambda_{jk}=\delta_{jk}R_{jk}/|R_{jk}|](https://latex.codecogs.com/svg.latex?\Lambda_{jk}=\delta_{jk}R_{jk}/|R_{jk}|), &nbsp; &nbsp; ![j,k=0,\dots,d-1](https://latex.codecogs.com/svg.latex?j,k=0,\dots,d-1),

where ![(Q,R)](https://latex.codecogs.com/svg.latex?(Q,R)) is the QR-decomposition of a Ginibre ensemble ![G](https://latex.codecogs.com/svg.latex?G):

![QR=G](https://latex.codecogs.com/svg.latex?QR=G), &nbsp; &nbsp; ![G_{jk}=\mathcal{N}_{jk,1}+\mathcal{N}_{jk,2}](https://latex.codecogs.com/svg.latex?G_{jk}=\mathcal{N}_{jk,1}+i\mathcal{N}_{jk,2}), &nbsp; &nbsp; ![j,k=0,\dots,d-1](https://latex.codecogs.com/svg.latex?j,k=0,\dots,d-1).

![\mathcal{N}_j](https://latex.codecogs.com/svg.latex?\mathcal{N}_j) are independent Gaussian random variables with zero mean and unit variance.

### <a name="haar_vec">Haar random vector state</a>

A random pure state in an arbitrary basis may be represented as the first column of a randum unitary matrix ![U](https://latex.codecogs.com/svg.latex?U) [[2](#ref2)]. The complex amplitudes of the state are:

![c_j=(\mathcal{N}_{j,1}+i\mathcal{N}_{j,2})/\sum_{j=0}^{d-1}{|c_j|^2}](https://latex.codecogs.com/svg.latex?c_j=\frac{\mathcal{N}_{j,1}+i\mathcal{N}_{j,2}}{\sqrt{\sum_{j=0}^{d-1}{|c_j|^2}}), &nbsp; &nbsp; ![j=0,\dots,d-1](https://latex.codecogs.com/svg.latex?j=0,\dots,d-1).

### <a name="haar_dm">Haar random density matrix</a>

A random density matrix may be represented by partial tracing of a Haar random vector state ![c](https://latex.codecogs.com/svg.latex?c), generated for the ![rd](https://latex.codecogs.com/svg.latex?rd)-dimensional Hilbert space, where ![r](https://latex.codecogs.com/svg.latex?r) is the number of degrees of freedom in latent space [[2](#ref2)]. This could be done by reshaping vector state into the ![{d}\times{r}](https://latex.codecogs.com/svg.latex?{d}\times{r}) matrix:

![\rho=\psi\psi^\dagger](https://latex.codecogs.com/svg.latex?\rho=\psi\psi^\dagger), &nbsp; &nbsp; ![\psi=( c_0&c_d&\cdots&c_{rd-d} \\ \vdots&\vdots&\ddots&\vdots \\ c_{d-1}&c_{2d-1}&\cdots&c_{rd-1})](https://latex.codecogs.com/svg.latex?\psi=\left(\begin{matrix}c_0&c_d&\cdots&c_{rd-d}\\%5C\vdots&\vdots&\ddots&\vdots\\%5Cc_{d-1}&c_{2d-1}&\cdots&c_{rd-1}\end{matrix}\right)).

For ![r<d](https://latex.codecogs.com/svg.latex?r<d) the rank of the output density matrix is usually equal to ![r](https://latex.codecogs.com/svg.latex?r). For ![r\geq{d}](https://latex.codecogs.com/svg.latex?r\geq{d}) the rank is ![d](https://latex.codecogs.com/svg.latex?d).

### <a name="bures">Bures random density matrix</a>

Bures distance between the density matrices ![\rho](https://latex.codecogs.com/svg.latex?\rho) and ![\sigma](https://latex.codecogs.com/svg.latex?\sigma) could be expressed using [fidelity](#TODO) ![d_B=\sqrt{2-2\sqrt{F(\rho,\sigma)}}](https://latex.codecogs.com/svg.latex?F(\rho,\sigma)):

![d_B=\sqrt{2-2\sqrt{F(\rho,\sigma)}}](https://latex.codecogs.com/svg.latex?d_B=\sqrt{2-2\sqrt{F(\rho,\sigma)}})

A random density matrix induced by this measure is [[3](#ref3)]

![\rho=\frac{AA^\dagger}{Tr(AA^\dagger)}](https://latex.codecogs.com/svg.latex?\rho=\frac{AA^\dagger}{\text{Tr}(AA^\dagger)}), &nbsp; &nbsp; ![A=(I+U)G](https://latex.codecogs.com/svg.latex?A=(I+U)G),

where ![I](https://latex.codecogs.com/svg.latex?I) &ndash; identity matrix, ![U](https://latex.codecogs.com/svg.latex?U) &ndash; random unitary matrix, ![G](https://latex.codecogs.com/svg.latex?G) &ndash; Ginibre ensemble: ![G_{jk}=\mathcal{N}_{jk,1}+\mathcal{N}_{jk,2}](https://latex.codecogs.com/svg.latex?G_{jk}=\mathcal{N}_{jk,1}+i\mathcal{N}_{jk,2}).

### <a name="refs">References</a>

<a name="ref1">[1]</a> F. Mezzadri. How to generate random matrices from the classical compact groups // Not. AMS 54, 592 (2007).

<a name="ref2">[2]</a> K. Zyczkowski, H.-J. Sommers. Induced measures in the space of mixed quantum states // J. Phys. A. Math. Gen. 34(35), 7111 (2001).

<a name="ref3">[3]</a> K. Zyczkowski et al. Generating random density matrices // J. Math. Phys. 52(6), 062201 (2011).
