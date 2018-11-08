

headers = $(wildcard include/*.h)

.PHONY: test time

read: main.cpp $(headers)
	g++ -std=c++11 -O2 -I include -o read main.cpp

time: read
	./read ../test2.csv
	./read ../test2.csv
	./read ../test2.csv

test: run_test
	./run_test

run_test: test.cpp $(headers)
	g++ -O2 -I include -o run_test test.cpp
	
