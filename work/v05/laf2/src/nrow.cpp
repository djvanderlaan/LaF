#include <Rcpp.h>
using namespace Rcpp;

#include "csvreader.h"
#include "eventhandlercountrows.h"

// [[Rcpp::export]]
double csv_nrow_cpp(std::string filename) {
  EventHandlerCountRows handler;
  CSVReader<EventHandlerCountRows> reader(filename, handler);
  reader.parse();
  return handler.nrow();
}

