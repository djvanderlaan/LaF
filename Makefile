
.PHONY: readme install test check build

all: readme 

readme: README.md

README.md: README.Rmd
	R  --vanilla --slave -e "library(knitr); knit('README.Rmd')"


install:
	R --vanilla --slave -e "devtools::install()"

test:
	R --vanilla --slave -e "devtools::test()"

check:
	R --vanilla --slave -e "devtools::check()"

build: 
	R --vanilla --slave -e "devtools::build()"

