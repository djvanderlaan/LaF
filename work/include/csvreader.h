#ifndef csvreader_h
#define csvreader_h

#include "columns.h"
#include "buffer.h"

#include <array>
#include <cstdlib>

#include <iostream>
#include <iomanip>


const std::size_t text_buffer_size = 1024;

class CSVReader {
  public:
    enum State {NEWREC, INREC, INRECQ, ENDREC};
    enum QuoteType {NONE, DOUBLE, BACKSLASH, BOTH};

    CSVReader(const std::string& filename) : ncolumns_(0), read_buffer_(filename), state_(NEWREC),
      quote_(BOTH) {
    }

    void add_column(Column* col) {
      if (ncolumns_ == 1024) throw std::runtime_error("Too many columns.");
      columns_[ncolumns_++] = col;
    }

    void quote_type(QuoteType quote) { quote_ = quote;};
    QuoteType quote_type() const { return quote_;};

    void start_reading() {
      for (std::size_t i = 0; i < ncolumns_; ++i)
        columns_[i]->start_reading();
    }

    void finished_reading() {
      for (std::size_t i = 0; i < ncolumns_; ++i)
        columns_[i]->finished_reading();
    }

    void new_record() {
      if (col_ >= ncolumns_) throw std::runtime_error("Row contains too many columns.");
      columns_[col_]->parse(buffer_.data(), buffer_pos_);
      col_++;
    }

    void end_of_line() {
     col_ = 0;
     row_++;
    }


    void parse() {
      start_reading();
      row_ = 0;
      col_ = 0;
      while (char c = read_buffer_.next()) {
        switch (state_) {
          case NEWREC: state_newrec(c); break;
          case INREC: state_inrec(c); break;
          case INRECQ: state_inrecq(c); break;
          case ENDREC: state_endrec(c); break;
        }
      }
      finished_reading();
    }
 
  protected:
    void state_newrec(char c) {
      switch (c) {
        case '"':
          buffer_pos_ = 0;
          state_ = INRECQ;
          break;
        case '\n':
        case '\r':
          break;
        default: 
          buffer_pos_ = 0;
          buffer_[buffer_pos_++] = c;
          // TODO?: check overflow
          state_ = INREC;
      }
    }

    void state_inrec(char c) {
      switch (c) {
        case '\n':
          new_record();
          end_of_line();
          state_ = NEWREC;
          break;
        case ',':
          new_record();
          state_ = NEWREC;
          break;
        default: 
          buffer_[buffer_pos_++] = c;
      }
    }

    void state_inrecq(char c) {
      if (c == '"') {
        if (quote_ == DOUBLE || quote_ == BOTH) {
          char c2 = read_buffer_.peek();
          if (c2 == '"') {
            buffer_[buffer_pos_++] = c;
            read_buffer_.next();
            return;
          }
        } 
        new_record();
        state_ = ENDREC;
        return;
      } else if (c == '\\' && (quote_ == BACKSLASH || quote_ == BOTH)) {
        char c2 = read_buffer_.peek();
        if (c2 == '"') {
          buffer_[buffer_pos_++] = '"';
          read_buffer_.next();
          return;
        }
      }
      buffer_[buffer_pos_++] = c;
    }

    void state_endrec(char c) {
      switch (c) {
        case '\n':
        case '\r':
          end_of_line();
        case ',':
          state_ = NEWREC;
          break;
        default: 
          {};
          //ERROR
      }
    }

  private:
    std::array<Column*, 1024> columns_;
    std::size_t ncolumns_;
    // Input buffer; reads from file and provides characters
    Buffer read_buffer_;
    // Field buffer; contents of field are punt into this buffer before 
    // conversion
    std::array<char, text_buffer_size> buffer_;
    std::size_t buffer_pos_;
    // State of parser
    State state_;
    // Current position in file
    std::size_t row_;
    std::size_t col_;
    // Handle escapes: \" = " or  "" = " or none
    QuoteType quote_;
};

#endif
