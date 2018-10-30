#include <iostream>
#include <iomanip>
#include <fstream>
#include <array>

#include <cstdlib>
#include "atoif.h"

const size_t max_buffer_size = 1E5;

class Buffer {
  public:
    Buffer(const std::string& filename) : filename_(filename), 
        file_(filename, std::ios::in|std::ios::binary), buffer_size_(0), 
        pos_(0) {
    }

    ~Buffer() {}

    char next() {
      if (pos_ >= buffer_size_) {
        // read next block of data
        file_.read(buffer_.data(), max_buffer_size);
        buffer_size_ = file_.gcount();
        pos_ = 0;
        if (buffer_size_ == 0) return 0;
      }
      return buffer_[pos_++];
    }

    char peek() {
      if (pos_ >= buffer_size_) {
        // read next block of data
        file_.read(buffer_.data(), max_buffer_size);
        buffer_size_ = file_.gcount();
        pos_ = 0;
        if (buffer_size_ == 0) return 0;
      }
      return buffer_[pos_];
    }

  private:
    std::string filename_;
    std::fstream file_;
    std::array<char, max_buffer_size> buffer_;
    std::size_t buffer_size_;
    std::size_t pos_;
};

void print_char(std::ostream& out, char c) {
  if (c == '\n') {
    out << "<newline>";
  } else if (c == '\r') {
    out << "<carriage return>";
  } else if (c == 0) {
    out << "<0>";
  } else {
    out << "'" << c << "'";
  }
}


enum csv_reader_state {NEWREC, INREC, INRECQ, ENDREC};
const std::size_t text_buffer_size = 1024;

class CSVReader {
  public:
    enum State {NEWREC, INREC, INRECQ, ENDREC};

    CSVReader(const std::string& filename) : read_buffer_(filename), state_(NEWREC) {
    }

    void start_reading() {
      sum_ = 0;
    }

    void finished_reading() {
      std::cout << sum_ << std::endl;
    }

    void new_record() {
      //std::string str(buffer_.data(), buffer_pos_);
      //std::cout << row_ << "," << col_ << "'" << str << "'\n";
      //atoi(buffer_.data(), buffer_pos_);
      //sum_ += atoi.value();
      sum_ += atoif(buffer_.data(), buffer_pos_);
      //buffer_[buffer_pos_] = 0;
      //sum_ += std::atoi(buffer_.data());
      col_++;
    }

    void end_of_line() {
     col_ = 0;
     row_++;
    }

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
      switch (c) {
        case '"': 
          new_record();
          state_ = ENDREC;
          break;
        default:
          buffer_[buffer_pos_++] = c;
      }
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

  private:
    Buffer read_buffer_;

    std::array<char, text_buffer_size> buffer_;
    std::size_t buffer_pos_;

    State state_;
    std::size_t row_;
    std::size_t col_;
    std::size_t i;
    int sum_;
};

int main(int argc, char* argv[]) {
  if (argc < 2) std::cerr << "Missing filename" << std::endl;
  std::string filename = argv[1];
  //Buffer buffer(filename);
  std::cout << filename << std::endl;

  CSVReader reader(filename);
  reader.parse();

  /*int i = 0;
  csv_reader_state state = NEWREC;
  while (char c = buffer.next()) {

    if (state == NEWREC) {
      switch (c) {
        case '"':
          state = INRECQ;
          break;
        case '\n':
        case '\r':
        default: 
          // ADD TO BUFFER
          state = INREC;
      }
    } else if (state == INREC) {
      switch (c) {
        case '\n':
        case ',':
          ++i;
          state = NEWREC;
          break;
      }
    } else if (state == INRECQ) {
      switch (c) {
        case '"': 
          ++i;
          state = ENDREC;
          break;
      }
    } else if (state == ENDREC) {
      switch (c) {
        case ',':
        case '\n':
        case '\r':
          state = NEWREC;
          break;
        default: 
          {};
          //ERROR
      }
    } 
    //std::cout << i << ": ";
    //print_char(std::cout, c);
    //std::cout << "\t\tnext: ";
    //print_char(std::cout, buffer.peek());
    //std::cout << std::endl;
    //i++;
  }
  std::cout << i << std::endl;*/
  return 0;
}
