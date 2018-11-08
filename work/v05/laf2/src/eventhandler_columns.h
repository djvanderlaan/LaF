#ifndef eventhandler_columns_h
#define eventhandler_columns_h

#include "arraycolumn.h"

class EventHandlerColumns {
  public:
    EventHandlerColumns() : ncolumns_(0) {
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

#endif
