#include <thread>
#include <mutex>
#include <chrono>
#include <array>

#include <iostream>
#include <iomanip>


class Buffer {
  public:
    Buffer(int max_val): current_slice_(1), max_val_(max_val), pos_(0) {
      slices_[0].buffer = buffer_.data();
      slices_[0].size   = 0;
      slices_[1].buffer = buffer_.data() + 10;
      slices_[1].size   = 0;
      std::cout << "Locking slice: 1" << std::endl;
      slices_[0].mutex.lock();
      slices_[1].mutex.lock();
      std::cout << "Locked slice 1" << std::endl;
      // Start thread that fills slices
      read_thread_ = std::thread(&Buffer::fill_buffer, this);
      std::cout << "Started thread" << std::endl;
    }

    ~Buffer() {
      std::cout << "Joining threads" << std::endl;
      if (read_thread_.joinable()) read_thread_.join();
    }

    int next() {
      // When end of buffer slice reached; go to next
      if (pos_ >= slices_[current_slice_].size) {
        std::size_t next_slice = (current_slice_ + 1) % 2;
        std::cout << "Locking next slice: " << next_slice << std::endl;
        slices_[next_slice].mutex.lock();
        std::cout << "Unlocking current slice: " << current_slice_ << std::endl;
        slices_[current_slice_].mutex.unlock();
        std::cout << "Next slice is current slice" << std::endl;
        current_slice_ = next_slice;
        pos_ = 0;
        if (slices_[current_slice_].size == 0) return 0;
      }
      std::cout << "Returning value at " << pos_ << std::endl;
      return slices_[current_slice_].buffer[pos_++];
    }

  private:

    struct BufferSlice {
      int* buffer;
      std::size_t size;
      std::mutex mutex;
    };

    std::array<int, 2 * 10> buffer_;
    std::array<BufferSlice, 2> slices_;
    std::size_t current_slice_;
    std::thread read_thread_;

    void fill_buffer() {
      int val = 1;
      std::size_t current_slice = 0;
      bool first = true;
      // lock current slice
      while (true) {
        // TODO: use lock guard ipv manual lock
        if (!first) slices_[current_slice].mutex.lock();
        first = false;
        slices_[current_slice].size = 0;
        // check if finished
        if (val > max_val_) {
          slices_[current_slice].mutex.unlock();
          return;
        }
        // fill slice
        for (std::size_t i = 0; i < 10 && val <= max_val_; ++i, ++val) {
          slices_[current_slice].buffer[i] = val;
          slices_[current_slice].size = i+1;
        }
        slices_[current_slice].mutex.unlock();
        // go to next slice
        current_slice = (current_slice + 1) % 2;
      }
    }

  private:
    int max_val_;
    std::size_t pos_;
};

int main(int argc, char* argv[]) {
  Buffer buffer(1);

  while (int c = buffer.next()) {
    std::cout << c << std::endl;
  }
  return 0;
}
