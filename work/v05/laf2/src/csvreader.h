#ifndef csvreader_h
#define csvreader_h

#include "buffer.h"

#include <array>
#include <cstdlib>

const std::size_t text_buffer_size = 1024;

template<typename T>
class CSVReader {
  public:
    enum State {NEWREC, INREC, INRECQ, ENDREC};
    enum QuoteType {NONE, DOUBLE, BACKSLASH, BOTH};

    CSVReader(const std::string& filename, T& event_handler) :  read_buffer_(filename), 
      state_(NEWREC), quote_(BOTH), event_handler_(event_handler) {
    }

    void quote_type(QuoteType quote) { quote_ = quote;};
    QuoteType quote_type() const { return quote_;};

    void parse() {
      event_handler_.start_reading();
      while (char c = read_buffer_.next()) {
        switch (state_) {
          case NEWREC: state_newrec(c); break;
          case INREC: state_inrec(c); break;
          case INRECQ: state_inrecq(c); break;
          case ENDREC: state_endrec(c); break;
        }
      }
      event_handler_.finished_reading();
    }
 
  protected:
    // State handlers for parser
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
          event_handler_.new_record(buffer_.data(), buffer_pos_);
          event_handler_.end_of_line();
          state_ = NEWREC;
          break;
        case ',':
          event_handler_.new_record(buffer_.data(), buffer_pos_);
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
        event_handler_.new_record(buffer_.data(), buffer_pos_);
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
          event_handler_.end_of_line();
        case ',':
          state_ = NEWREC;
          break;
        default: 
          {};
          //ERROR
      }
    }

  private:
    // Input buffer; reads from file and provides characters
    Buffer read_buffer_;
    // Field buffer; contents of field are punt into this buffer before 
    // conversion
    std::array<char, text_buffer_size> buffer_;
    std::size_t buffer_pos_;
    // State of parser
    State state_;
    // Handle escapes: \" = " or  "" = " or none
    QuoteType quote_;
    // Eventhandler
    T& event_handler_;
};

#endif
