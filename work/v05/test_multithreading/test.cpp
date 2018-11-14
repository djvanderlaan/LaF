
#include <thread>
#include <mutex>
#include <iostream>
#include <iomanip>
#include <chrono>
#include <array>

class Test {
  public:
    Test() : cur_buffer_(0), buffer_len_(0), pos_(0), count_(0) {};

    ~Test() {
      thread_fill_.join();
      thread_fill_.join();
    }

    void test() {
      v = 1;
      std::cout << "starting first helper...\n";
      std::thread helper1(&Test::foo, this);

      std::cout << "starting second helper...\n";
      std::thread helper2(&Test::bar, this);

      std::cout << "waiting for helpers to finish..." << std::endl;
      helper1.join();
      helper2.join();

      std::cout << "done!\n";
    }

    int get() {
      if (pos_ >= buffer_len_) {
        // initial situation
        if (cur_buffer_ == 0) {
          std::cout << "Initial" << std::endl;
          cur_buffer_ = &buffer2_;
          thread_fill_ = fill_buffer_thr();
        }
        // wait for previous thread to finish
        std::cout << "Wait" << std::endl;
        thread_fill_.join();
        // set current buffer to the buffer that was just filled
        std::cout << "Flip buffer" << std::endl;
        if (cur_buffer_ == &buffer1_) {
          std::cout << "Buffer1" << std::endl;
          cur_buffer_ = &buffer2_;
        } else {
          std::cout << "Buffer2" << std::endl;
          cur_buffer_ = &buffer1_;
        }
        pos_ = 0;
        buffer_len_ = 10;
        // start new thread to fill next buffer
        std::cout << "New thread" << std::endl;
        thread_fill_ = fill_buffer_thr();
      }
      return (*cur_buffer_)[pos_++];
    }

  private:
    typedef std::array<int, 10> Buf;

    void foo() {
      int w = v + 1;
      // simulate expensive operation
      std::this_thread::sleep_for(std::chrono::seconds(w));
    }
 
    void bar() {
      int w = v + 10;
      // simulate expensive operation
      std::this_thread::sleep_for(std::chrono::seconds(w));
    }

    std::thread fill_buffer_thr() {
      return std::thread(&Test::fill_buffer2, this);
    }

    void fill_buffer2() {
      if (cur_buffer_ == &buffer1_) {
        for (int i = 0; i < buffer2_.size(); ++i) {
          buffer2_.data()[i] = count_++;
        }
      } else {
        for (int i = 0; i < buffer1_.size(); ++i) {
          buffer1_.data()[i] = count_++;
        }
      }
    }

    void fill_buffer(Buf* buf) {
      for (int i = 0; i < buf->size(); ++i) {
        buf->data()[i] = count_++;
      }
    }

  private:
    int v;

    Buf buffer1_;
    Buf buffer2_;
    Buf* cur_buffer_;
    int buffer_len_;
    int pos_;
    std::thread thread_fill_;

    int count_;
};

int main(int argc, char* argv[]) {
  Test test;
  //test.test();

  for (int i = 0; i < 100; ++i) {
    std::cout << test.get() << std::endl;
  }
  return 0;
}

