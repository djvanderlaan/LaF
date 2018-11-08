#include <Rcpp.h>
using namespace Rcpp;

#include "csvreader.h"
#include "eventhandler_columns.h"
#include <vector>

// [[Rcpp::export]]
List csv_read_cpp(std::string filename) {
  // Set up event handler
  EventHandlerColumns handler;
  std::vector<ArrayColumn<int>*> columns_;
  for (int i = 0; i < 7; ++i) {
    ArrayColumn<int>* col = new ArrayColumn<int>();
    columns_.push_back(col);
    handler.add_column(col);
  }
  // Open and read file
  CSVReader<EventHandlerColumns> reader(filename, handler);
  reader.parse();
  // Copy data to R-structures
  List res(7);
  for (int i = 0; i < 7; ++i) {
    res[i] = IntegerVector(columns_[i]->data(), 
      columns_[i]->data() + columns_[i]->size());
  }
  // Cleanup memory
  for (auto p = columns_.begin(); p != columns_.end(); ++p) {
    ArrayColumn<int>* col = *p;
    delete col;
    *p = 0;
  }
  return res;
}
