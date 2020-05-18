# qtb_compare
Compares benchmarks of QT methods based on [qtb_analyze](qtb_analyze.md) raw outputs. The results are sorted according to the sample size benchmark.

[**&#8592; Back to contents**](README.md)

## Usage
* `report = qtb_compare(results, tcode)` returns the compare report based on a set of [qtb_analyze](qtb_analyze.md) raw outputs [results](#arg-results) for a specified test codename [tcode](#arg-tcode)
* `report = qtb_compare( ___ ,Name,Value)` specifies additional arguments using one or more [Name-Value pairs](#args-nv)

## <a name="args">Input arguments</a>

### <a name="arg-results">results</a>
_**Data type:**_ cell array

A cell array of QT methods raw analysis results. Each element of the array is a path to analysis result file or the result [structure array](qtb_analyze.md#output).

### <a name="arg-tcode">tcode</a>
_**Data type:**_ char

The codename of the test to compare.

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-names">names</a>
_**Data type:**_ cell array

A cell array of QT methods display names. If the array is empty display names are based on the `name` field of results [structure arrays](qtb_analyze.md#output).

_**Default:**_ `{}`

### <a name="arg-error_rate">error_rate</a>
_**Data type:**_ double

Error rate to compare QT methods bemchmarks.

_**Default:**_ `1e-3`

### <a name="arg-plot">plot</a>
_**Data type:**_ char

Plot type for infidelity vs sample size plot. Available values:
* `'none'` - do not make a plot
* `'percentile'` - [percentile](#arg-percentile) plot
* `'stats'` - median plot with 25-th and 75-th percentiles errorbar
* `'mean'` - mean value plot

_**Default:**_ `'none'`

### <a name="arg-percentile">percentile</a>
_**Data type:**_ double

The percentile value for QT method benchmarks comparison and [percentile plot](#arg-plot).

_**Default:**_ `95`

### <a name="arg-bound">bound</a>
_**Data type:**_ logical

Show theoretical lower bound in the compare table and plot.

_**Default:**_ true

### <a name="arg-export">export</a>
_**Data type:**_ char

Path to file to export the compareison report as a table. Available formats: \*xls, \*xlsx, \*csv.

_**Default:**_ `'none'`

## <a name="output">Function output</a>
_**Data type:**_ structure array

Function output `report` is a structure array containing report data:
* `report.names` - QT methods names
* `report.fields` - cell array of benchmarks names (see [benchmarks page](benchmarks.md))
* `report.data` - array of benchmarks values: each row contains benchmark values for a given QT method (sorted by `'NSamples'` field)
* `report.table` - table array of benchmarks values
* `report.figure` - figure object (if [plot](#arg-plot) is not `'none'`)
