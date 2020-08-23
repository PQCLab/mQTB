# Tests specification
Current page describes the methods of quantum states generation and the quantum tomography tests currently implemented.

[**&#8592; Back to contents**](README.md)

## Tests description

### Random pure states
* _Codename_: rps
* _Rank_: 1
* _Number of experiments_: 1000
* _State generator_
  * _Type_: Haar random (![r=1](https://latex.codecogs.com/svg.latex?r=1))

### Random mixed states by partial tracing: rank-2
  * _Codename_: rmspt_2
  * _Rank_: 2
  * _Number of experiments_: 1000
  * _State generator_
    * _Type_: Haar random (![r=2](https://latex.codecogs.com/svg.latex?r=2))

### Random mixed states by partial tracing: rank-d
  * _Codename_: rmspt_d
  * _Rank_: full
  * _Number of experiments_: 1000
  * _State generator_
    * _Type_: Haar random (![r=d](https://latex.codecogs.com/svg.latex?r=d))

### Random noisy preparation
  * _Codename_: rnp
  * _Rank_: full
  * _Number of experiments_: 1000
  * _State generator_
    * _Type_: Haar random (![r=1](https://latex.codecogs.com/svg.latex?r=1))
    * _Initialization error_: ![\text{unirnd}(0,0.05)](https://latex.codecogs.com/svg.latex?\text{unirnd}(0,0.05))
    * _Depolarization probability_: ![\text{unirnd}(0,0.01)](https://latex.codecogs.com/svg.latex?\text{unirnd}(0,0.01))

## State generators

In each numerical experiment quantum states are generated using random number generator. To generate states we use
* normally distributed random variables ![\text{normrnd}(\mu,\sigma)](https://latex.codecogs.com/svg.latex?\text{normrnd}(\mu,\sigma)) with mean ![\mu](https://latex.codecogs.com/svg.latex?\mu) and standard deviation ![\sigma](https://latex.codecogs.com/svg.latex?\sigma)
* uniformly distributed random variables ![\text{unirnd}(a,b)](https://latex.codecogs.com/svg.latex?\text{unirnd}(a,b)) from ![a](https://latex.codecogs.com/svg.latex?a) to ![b](https://latex.codecogs.com/svg.latex?b)

Below we consider different types of random quantum states in a ![d](https://latex.codecogs.com/svg.latex?d)-dimensional Hilbert space. Some of them are induced by the Haar measure on the unitary group ![U(d)](https://latex.codecogs.com/svg.latex?U(d)). A random unitary matrix ![U](https://latex.codecogs.com/svg.latex?U) according to this measure has the form [[1](#ref1)]

![U=Q\Lambda](https://latex.codecogs.com/svg.latex?U=Q\Lambda), &nbsp; &nbsp; ![\Lambda_{jk}=\delta_{jk}R_{jk}/|R_{jk}|](https://latex.codecogs.com/svg.latex?\Lambda_{jk}=\delta_{jk}R_{jk}/|R_{jk}|), &nbsp; &nbsp; ![j,k=0,\dots,d-1](https://latex.codecogs.com/svg.latex?j,k=0,\dots,d-1),

where ![(Q,R)](https://latex.codecogs.com/svg.latex?(Q,R)) is the QR-decomposition of a Ginibre ensemble ![G](https://latex.codecogs.com/svg.latex?G):

![QR=G](https://latex.codecogs.com/svg.latex?QR=G), &nbsp; &nbsp; ![G_{jk}=\mathcal{N}_{jk,1}+\mathcal{N}_{jk,2}](https://latex.codecogs.com/svg.latex?G_{jk}=\mathcal{N}_{jk,1}+i\mathcal{N}_{jk,2}), &nbsp; &nbsp; ![j,k=0,\dots,d-1](https://latex.codecogs.com/svg.latex?j,k=0,\dots,d-1).

![\mathcal{N}_j\sim\text{normrnd}(0,1)](https://latex.codecogs.com/svg.latex?\mathcal{N}_j\sim\text{normrnd}(0,1)).

### <a name="haar_vec">Haar random vector state</a>

A random pure state in an arbitrary basis may be represented as the first column of a random unitary matrix ![U](https://latex.codecogs.com/svg.latex?U) [[2](#ref2)]. The complex amplitudes of the state are:

![c_j=(\mathcal{N}_{j,1}+i\mathcal{N}_{j,2})/\sum_{j=0}^{d-1}{|c_j|^2}](https://latex.codecogs.com/svg.latex?c_j=\frac{\mathcal{N}_{j,1}+i\mathcal{N}_{j,2}}{\sqrt{\sum_{j=0}^{d-1}{|c_j|^2}}), &nbsp; &nbsp; ![j=0,\dots,d-1](https://latex.codecogs.com/svg.latex?j=0,\dots,d-1).

### <a name="haar_dm">Haar random density matrix</a>

A random density matrix may be represented by partial tracing of a Haar random vector state ![c](https://latex.codecogs.com/svg.latex?c), generated for the ![rd](https://latex.codecogs.com/svg.latex?rd)-dimensional Hilbert space, where ![r](https://latex.codecogs.com/svg.latex?r) is the number of degrees of freedom in latent space [[2](#ref2)]. This could be done by reshaping vector state into the ![{d}\times{r}](https://latex.codecogs.com/svg.latex?{d}\times{r}) matrix:

![\rho=\psi\psi^\dagger](https://latex.codecogs.com/svg.latex?\rho=\psi\psi^\dagger), &nbsp; &nbsp; ![\psi=( c_0&c_d&\cdots&c_{rd-d} \\ \vdots&\vdots&\ddots&\vdots \\ c_{d-1}&c_{2d-1}&\cdots&c_{rd-1})](https://latex.codecogs.com/svg.latex?\psi=\left(\begin{matrix}c_0&c_d&\cdots&c_{rd-d}\\%5C\vdots&\vdots&\ddots&\vdots\\%5Cc_{d-1}&c_{2d-1}&\cdots&c_{rd-1}\end{matrix}\right)).

For ![r<d](https://latex.codecogs.com/svg.latex?r<d) the rank of the output density matrix is ![r](https://latex.codecogs.com/svg.latex?r). For ![r\geq{d}](https://latex.codecogs.com/svg.latex?r\geq{d}) the rank is ![d](https://latex.codecogs.com/svg.latex?d).

### <a name="bures">Bures random density matrix</a>

Bures distance between the density matrices ![\rho](https://latex.codecogs.com/svg.latex?\rho) and ![\sigma](https://latex.codecogs.com/svg.latex?\sigma) could be expressed using [fidelity](qtb_analyze.md#fidelity) ![d_B=\sqrt{2-2\sqrt{F(\rho,\sigma)}}](https://latex.codecogs.com/svg.latex?F(\rho,\sigma)):

![d_B=\sqrt{2-2\sqrt{F(\rho,\sigma)}}](https://latex.codecogs.com/svg.latex?d_B=\sqrt{2-2\sqrt{F(\rho,\sigma)}})

A random density matrix induced by this measure is [[3](#ref3)]

![\rho=\frac{AA^\dagger}{Tr(AA^\dagger)}](https://latex.codecogs.com/svg.latex?\rho=\frac{AA^\dagger}{\text{Tr}(AA^\dagger)}), &nbsp; &nbsp; ![A=(I+U)G](https://latex.codecogs.com/svg.latex?A=(I+U)G),

where ![I](https://latex.codecogs.com/svg.latex?I) &ndash; identity matrix, ![U](https://latex.codecogs.com/svg.latex?U) &ndash; random unitary matrix, ![G](https://latex.codecogs.com/svg.latex?G) &ndash; Ginibre ensemble: ![G_{jk}=\mathcal{N}_{jk,1}+\mathcal{N}_{jk,2}](https://latex.codecogs.com/svg.latex?G_{jk}=\mathcal{N}_{jk,1}+i\mathcal{N}_{jk,2}).

### <a name="init_err">Initialization error</a>

Consider a system with ![n](https://latex.codecogs.com/svg.latex?n) subsystems with dimensions ![d_1,\dots,d_n](https://latex.codecogs.com/svg.latex?d_1,\dots,d_n). Usually each subsystem is initialized in the state ![\left|0\right>](https://latex.codecogs.com/svg.latex?\left|0\right>). We consider a noisy initialization in a state ![\rho_0](https://latex.codecogs.com/svg.latex?\rho_0) where the initial state of each subsystem is ![(1-e_0)\left|0\right>\left<0right|+e_0\left|1\right>\left<1right|](https://latex.codecogs.com/svg.latex?(1-e_0)\left|0\right>\left<0\right|&plus;e_0\left|1\right>\left<1\right|). The value of ![e_0](https://latex.codecogs.com/svg.latex?e_0) characterizes initialization error. It could be fixed or set randomly.

We then replace eigenvalues of the generated quantum state with eigenvalues (diagonal) of the state ![\rho_0](https://latex.codecogs.com/svg.latex?\rho_0).

_**Note:**_ current state modification works properly only for a rank-1 random quantum state.

### <a name="depol">Depolarization</a>

Depolarization channel performs the following transformation over a density matrix: ![\rho\rightarrow(1-p)\rho+pI/d](https://latex.codecogs.com/svg.latex?\rho\rightarrow(1-p)\rho&plus;pI/d), where ![p](https://latex.codecogs.com/svg.latex?p) is the depolarization probability. The value of depolarization probability could be fixed or set randomly.

## <a name="refs">References</a>

<a name="ref1">[1]</a> F. Mezzadri. How to generate random matrices from the classical compact groups // Not. AMS 54, 592 (2007).

<a name="ref2">[2]</a> K. Zyczkowski, H.-J. Sommers. Induced measures in the space of mixed quantum states // J. Phys. A. Math. Gen. 34(35), 7111 (2001).

<a name="ref3">[3]</a> K. Zyczkowski et al. Generating random density matrices // J. Math. Phys. 52(6), 062201 (2011).
