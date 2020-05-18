# qtb_plot
Plots statistical data in the form of the box plot

[**&#8592; Back to contents**](README.md)

## Usage
* `qtb_plot(x,y)` makes an anjusted box plot of [y](#arg-y) versus [x](#arg-x), where [x](#arg-x) is a vector and [y](#arg-y) is a matrix with statistical data distributed along the dimension 1
* `qtb_plot(x,y,dim)` specifies the dimension [dim](#arg-dim) along which statistical data is distributed in [y](#arg-y)
* `qtb_plot( ___ ,Name,Value)` specifies additional arguments using one or more [Name-Value pairs](#args-nv)
* `[hb,hw,ho] = qtb_plot( ___ )` returns graphical handles of box `hb`, whiskers `hw` and outliers `ho` plots

## <a name="args">Input arguments</a>

### <a name="arg-x">x</a>
_**Data type:**_ vector

X-values of a 2d-plot.

### <a name="arg-y">y</a>
_**Data type:**_ matrix

Statistical data. If [dim](#arg-dim) is 1 than `size(y,2) == length(x)` must be satisfied. Otherwise, `size(y,1) == length(x)`.

### <a name="arg-dim">dim</a>
_**Data type:**_ scalar

Dimension along which the statistical data is distributed.

_**Default:**_ `1`

## <a name="args-nv">Name-Value pair arguments</a>

### <a name="arg-name">name</a>
_**Data type:**_ char

Plot name to display in legend.

_**Default:**_ `''`

### <a name="arg-name">color</a>
_**Data type:**_ vector | integer

RGB vector of plot color or integer index of color in default colormap.

_**Default:**_ `1`

### <a name="arg-style">style</a>
_**Data type:**_ char

Line style of a plot (see MATLAB plot line specification).

_**Default:**_ `'-'`

### <a name="arg-show_whiskers">show_whiskers</a>
_**Data type:**_ logical

Set to `false` to hide whiskers.

_**Default:**_ `true`

### <a name="arg-show_outs">show_outs</a>
_**Data type:**_ logical

Set to `false` to hide outliers.

_**Default:**_ `true`

### <a name="arg-outs_size">outs_size</a>
_**Data type:**_ scalar

Size of markers in outliers scatter plot.

_**Default:**_ `8`

## <a name="output">Function output</a>
_**Data type:**_ graphical handle

Graphical handles of box `hb`, whiskers `hw` and outliers `ho` plots.
