# Documentation

This is the documentation of MATLAB library for the benchmarking of quantum tomography (QT) methods. Installation instructions and basic examples are given at the [**home page**](https://github.com/PQCLab/mQTB/).

## Table of contents

* [**Getting started**](/README.md)
* **Main functions**
  * qtb_startup - prepares library
  * qtb_config - returns library configuration
  * [qtb_analyze](qtb_analyze.md) - performs analyzis of a QT method
  * [qtb_report](qtb_report.md) - reports benchmarks of the QT method
  * [qtb_compare](qtb_compare.md) - compares QT methods banchmarks
  * [qtb_tests](qtb_tests.md) - returns a set of all available tests
* **Utils**
  * qtb_result - analysis results class
  * [qtb_state](qtb_state.md) - generates a random quantum state
  * [qtb_proto](qtb_proto.md) - generates a measurement protocol
  * [qtb_plot](qtb_plot.md) - plots statistical data
  * qtb_stats - functions to work with statistics
  * qtb_tools - additional tools
* **Helpers**
  * [static_proto](static_proto.md) - generates [protocol handler](qtb_analyze.md#arg-fun_proto) for static (non-adaptive) protocols
  * [iterative_proto](iterative_proto.md) - generates [protocol handler](qtb_analyze.md#arg-fun_proto) for iterative protocols
  * qn_state_analyze - wrapper for qubit state tomography analysis
* **QT methods**
  * Protocols
    * [proto_fmub](proto_fmub.md) - factorized mutually unbiased bases measurements
    * [proto_pauli](proto_fmub.md) - Pauli measurements of qubits
    * [proto_mub](proto_mub.md) - mutually unbiased bases measurements
    * [proto_amub](proto_amub.md) - adaptive mutually unbiased bases measurements
  * Estimators
    * [est_ppi](est_ppi.md) - projected pseudo-inversion estimator
    * [est_frls](est_frls.md) - full rank least squares estimator
    * [est_frml](est_frml.md) - full rank maximum likelihood estimator
    * [est_trml](est_trml.md) - true rank maximum likelihood estimator
    * [est_arml](est_arml.md) - adequate rank maximum likelihood estimator
    * [est_cs](est_cs.md) - compressed sensing estimator
