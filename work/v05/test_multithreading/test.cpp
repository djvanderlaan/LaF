
#include <thread>
#include <mutex>
#include <iostream>
#include <iomanip>
#include <chrono>
#include <array>

int max_count = 95;

class Test {
  public:
    Test() : cur_parse_buffer_{nullptr,0}, cur_read_buffer_{nullptr,0}, pos_(0), count_(1) {};

    ~Test() {
      if (thread_fill_.joinable()) thread_fill_.join();
    }

    int get() {
      if (pos_ >= cur_parse_buffer_.len) {
        // initial situation
        if (cur_parse_buffer_.buf == 0) {
          cur_read_buffer_  = CurBuf{&buffer1_, 0};
          cur_parse_buffer_ = CurBuf{&buffer2_, 0};
          thread_fill_ = fill_buffer_thr();
        }
        // wait for previous thread to finish
        thread_fill_.join();
        // set current buffer to the buffer that was just filled
        std::swap(cur_parse_buffer_, cur_read_buffer_);
        pos_ = 0;
        // start new thread to fill next buffer
        thread_fill_ = fill_buffer_thr();
        if (cur_parse_buffer_.len == 0) return 0;
      }
      return cur_parse_buffer_.buf->data()[pos_++];
    }

  private:
    typedef std::array<int, 10> Buf;
    struct CurBuf {
      Buf* buf; 
      std::size_t len;
    };

    std::thread fill_buffer_thr() {
      return std::thread(&Test::fill_buffer, this);
    }

    void fill_buffer() {
      cur_read_buffer_.len = 0;
      for (int i = 0; i < cur_read_buffer_.buf->size() && count_ < max_count; ++i) {
        cur_read_buffer_.buf->data()[i] = count_++;
        cur_read_buffer_.len = i+1;
      }
    }

  private:
    int v;

    Buf buffer1_;
    Buf buffer2_;

    CurBuf cur_parse_buffer_;
    CurBuf cur_read_buffer_;

    int buffer_len_;
    int pos_;
    std::thread thread_fill_;

    int count_;
};

int main(int argc, char* argv[]) {
  Test test;

  while (int c = test.get()) {
    std::cout << c << std::endl;
  }
  return 0;
}

