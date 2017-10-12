

This is small update on a version (0.7.0) that I uploaded yesterday, where 
apparently an error in the documentation occured that didn't show up when
testing locally and using `rhub::check_for_cran()`. Don't now how that 
happened. This should be fixed now. Current version gives no warnings
on winbuilder.

The previous version is a small update on the previous release: 

- Fixed a memory leak
- Added a progress bar to one of the methods. 


## Test environments
* local ubuntu 17.04 install, R 3.4.1
* windows, linux, release and devel using `rhub::check_for_cran()`

## R CMD check results

0 errors | 0 warnings | 0 notes



