# nastranMagic for MATLAB

First off, run NASTRAN to obtain an .f06 file; then, in MATLAB, open a folder containing both the .f06 and _nastranMagic.m_. Now create a nastranMagic object with:

``` MATLAB
my_file = nastranMagic('file_name.f06');
```



## Time response

To parse time response and plot it, just call parseTimeResponse() function:

``` MATLAB
tr = my_file.parseTimeResponse();
```

where _tr_ is a matrix whose first coulumn contains values of time, while second column contains values of the selected component of the selected point at the corresponding time. Notice that the function will automatically plot time story.



## V-g diagram

To plot the V-g diagram of a selection of modes, use:

``` MATLAB
modes = [1 2 5]
my_file.plotVg(modes);
```

where _modes_ is a vector containing the numbers of the modes to be plotted (eg., this snippets prints the first, the second and the fifth mode).

To get the numerical values of the points of the V-g diagram:

``` MATLAB
vg = my_file.vgSingleMode();
```
where the first column of _vg_ contains velocities, the second values of g.



## To do and to be fixed
- properly comment the code
- allow user to select points/components
- frequency response
- bisection method to find zeroes on V-g plot (?)
