# qtb_tests
Returns the list of all the available tests.

[**&#8592; Back to contents**](README.md)

## Usage
* `tests = qtb_tests(dim)` returns tests list for a dimension array [dim](#arg-dim)

## <a name="args">Input arguments</a>

### <a name="arg-dim">dim</a>
_**Data type:**_ double

[Dimension array](qtb_analyze.md#dim-arr).

## <a name="output">Function output</a>
_**Data type:**_ structure array

Function output `tests` is a structure array describing all the available tests (see [tests specification page](tests_specification.md)).

For every test there is a unique codename `tcode`. The structure array `test = tests.(tcode)` describes the tests with the following fields:
* `test.code` - test code
* `test.name` - test name
* `test.seed` - seed for the test random number generator
* `test.nsample(1,k)` - _k_-th value of the total sample size used to test QT method
* `test.nexp` - number of QT experiments for every value of sample size
* `test.rank` - rank of the density matrices generated within the test
* `test.generator` - generator of the random quantum states

Generator of the quantum state is a cell array which elements correspond to the input arguments of [qtb_state](qtb_state.md).

_**Example:**_ `dm = qtb_state(dim, test.generator{:})`
