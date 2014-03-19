SOURCEDIR     = src
INCLUDEDIR    = include
TMPDIR        = tmp

CXX       = g++

CXXFLAGS  = -O3 -I$(SOURCEDIR) -ansi -Wall 
LIBS      = 

# RCPP
LIBS     += `Rscript -e "Rcpp:::LdFlags()"`
CXXFLAGS += `Rscript -e "Rcpp:::CxxFlags()"`

# R
#LIBS     +=  -lR 
LIBS      = -L/usr/lib/R/lib -lR
CXXFLAGS += -I/usr/share/R/include -fPIC

CXXFLAGSLINKER = -shared -s -static-libgcc

VPATH    = $(SOURCEDIR):$(TMPDIR)

target   = LaF
sources  = $(wildcard src/*.cpp)
objects  = $(notdir $(patsubst %.cpp, %.o, $(sources)))

$(target): $(objects) 
	@echo "Linking..."
	@$(CXX) $(CXXFLAGS) $(CXXFLAGSLINKER) -o $(target).so $(patsubst %.o,$(TMPDIR)/%.o,$(objects)) $(LIBS)

-include $(patsubst %.d,$(TMPDIR)/%.d,$(objects:.o=.d))
	
%.o: %.cpp
	@echo "Compiling $<..."
	@$(CXX) $(CXXFLAGS) -o $(TMPDIR)/$@ -c  $<

$(TMPDIR)/%.d: %.cpp
	@echo "Making dependencies for $<..."
	@$(CXX) -MM $(CXXFLAGS) $< > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

.PHONY: clean 

clean:
	@echo "Cleaning up..."
	@/bin/rm -f $(TMPDIR)/*.o $(TMPDIR)/*.d $(target).so

