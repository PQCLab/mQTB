# qtb_report
Reports benchmarks of the QT method based on [qtb_analyze](qtb_analyze.md) raw output.

[**&#8592; Back to contents**](README.md)

## Usage
* `report = qtb_report(result, tcode)` returns the report based on [qtb_analyze](qtb_analyze.md) raw output [result](#arg-result) for a specific test codename [tcode](#arg-tcode)
* `report = qtb_report( ___ ,Name,Value)` specifies additional arguments using one or more [Name-Value pairs](#args-nv)

## <a name="args">Input arguments</a>

### <a name="arg-result">result</a>
_**Data types:**_ char | structure array

Path to analysis result file or the result [structure array](qtb_analyze.md#output).

### <a name="arg-tcode">tcode</a>
_**Data type:**_ char

The codename of the test to report.

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-percentile">percentile</a>
_**Data type:**_ double

The percentile value for QT method benchmarks estimation.

_**Default:**_ `95`

### <a name="arg-error_rates">error_rates</a>
_**Data type:**_ double

An array of error rates to estimate QT methods benchmarks.

_**Default:**_ `[1e-1, 1e-2, 1e-3, 1e-4]`

### <a name="arg-plot">plot</a>
_**Data type:**_ logical

Make the plots of QT methods resources vs sample size.

_**Default:**_ `false`

### <a name="arg-export">export</a>
_**Data type:**_ char

Path to file to export the report as a table. Available formats: \*xls, \*xlsx, \*csv.

_**Default:**_ `'none'`

## <a name="output">Function output</a>
_**Data type:**_ structure array

Function output `report` is a structure array containing report data:
* `report.name` - QT method name
* `report.dim` - [dimension array](qtb_analyze.md#dim-arr) of the analysis results
* `report.tcode` - test codename
* `report.tname` - test name
* `report.percentile` - percentile specified for benchmarks estimation
* `report.error_rates` - error rates specified for benchmarks estimation
* `report.fields` - cell array of benchmarks names (see [benchmarks page](benchmarks.md))
* `report.data` - array of benchmarks values: each row contains benchmark values for a given error rate
* `report.table` - table array of benchmarks values
* `report.figure` - figure object (if [plot](#arg-plot) is set to `true`)
