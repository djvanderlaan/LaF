#ifndef buffer_h
#define buffer_h

#include <fstream>
#include <array>

const size_t max_buffer_size = 1E6;

class Buffer {
  public:
    Buffer(const std::string& filename, std::fstream::pos_type skip = 0) : filename_(filename), 
        file_(filename, std::ios::in|std::ios::binary), buffer_size_(0), 
        pos_(0) {
      if (skip) file_.seekg(skip);
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

#endif
