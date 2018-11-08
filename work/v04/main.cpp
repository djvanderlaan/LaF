
#include "csvreader.h"
#include "arraycolumn.h"

#include <iostream>
#include <iomanip>
#include <chrono>
#include <vector>

class MyEventHandler {
  public:
    MyEventHandler() : ncolumns_(0) {
    }

    void add_column(Column* col) {
      if (ncolumns_ == 1024) throw std::runtime_error("Too many columns.");
      columns_[ncolumns_++] = col;
    }


    void start_reading() {
      row_ = 0;
      col_ = 0;
      for (std::size_t i = 0; i < ncolumns_; ++i)
        columns_[i]->start_reading();
    }

    void finished_reading() {
      for (std::size_t i = 0; i < ncolumns_; ++i)
        columns_[i]->finished_reading();
    }

    void new_record(char* p, std::size_t len) {
      if (col_ >= ncolumns_) throw std::runtime_error("Row contains too many columns.");
      columns_[col_]->parse(p, len);
      col_++;
    }

    void end_of_line() {
      col_ = 0;
      row_++;
    }

  private:
    std::size_t row_;
    std::size_t col_;

    std::array<Column*, 1024> columns_;
    std::size_t ncolumns_;
};

int main(int argc, char* argv[]) {
  // Parse arguments
  if (argc < 2) std::cerr << "Missing filename" << std::endl;
  std::string filename = argv[1];
  std::cout << filename << std::endl;
  // Start time measurement
  auto t1 = std::chrono::high_resolution_clock::now();
  // Open file
  MyEventHandler handler;
  CSVReader<MyEventHandler> reader(filename, handler);
  // Add columns
  //IntColumn column;
  std::vector<ArrayColumn<double>*> columns_;
  for (int i = 0; i < 7; ++i) {
    ArrayColumn<double>* col = new ArrayColumn<double>();
    columns_.push_back(col);
    handler.add_column(col);
  }
  //DoubleColumn column;
  //for (int i = 0; i < 7; ++i) handler.add_column(&column);
  //PrintColumn column;
  //for (int i = 0; i < 3; ++i) reader.add_column(&column);
  // Parse
  reader.parse();
  // Stop time measurement
  auto t2 = std::chrono::high_resolution_clock::now();
  double tdif = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
  // Show results
  //std::cout << column.sum() << std::endl;
  std::cout << "Elapsed time: " << tdif/1000.0 << " seconds." << std::endl;

  for (auto p = columns_.begin(); p != columns_.end(); ++p) {
    ArrayColumn<double>* col = *p;
    delete col;
    *p = 0;
  }

  return 0;
}

