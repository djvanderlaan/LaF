LaF
===

The LaF package provides methods for fast access to large ASCII files. Currently the following file
formats are supported:

* comma separated format (csv) and other separated formats and
* fixed width format. 

It is assumed that the files are too large to fit into memory, although the package can also be used
to efficiently access files that do fit into memory. Methods are provided to access and process
files blockwise. Furthermore, an opened file can be accessed as one would an ordinary data.frame.
For example, assuming that an object laf has been created using one of the functions `laf_open_csv` or
`laf_open_fwf`, the third column from the file can be read into memory using:

    c <- laf[,3]

