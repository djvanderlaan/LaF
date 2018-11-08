#ifndef dynamicarray_h
#define dynamicarray_h

#include <cstdlib>
#include <new>

template<typename T>
class DynamicArray {
  public:
    DynamicArray(std::size_t size = 1024) : arr_(nullptr), len_(size), pos_(0) {
      resize(len_);
    }

    ~DynamicArray() {
      std::free(arr_);
    }

    std::size_t size() const { return pos_;}
    const T* data() const { return arr_;}

    void push_back(T val) {
      if (pos_ >= len_) {
        resize();
      }
      arr_[pos_++] = val;
    }

    void truncate() {
      resize(pos_);
    }

  private:
    void resize() {
      std::size_t new_size = 2 * len_;
      resize(new_size);
    }

    void resize(std::size_t new_size) {
      if (new_size == 0) { 
	std::free(arr_);
	arr_ = nullptr;
      } else {
	if (void* mem = std::realloc(arr_, sizeof(T)*new_size))
	  arr_ = static_cast<T*>(mem);
	else throw std::bad_alloc();
      }
      len_ = new_size;
    }

  private:
    T* arr_;
    std::size_t len_;
    std::size_t pos_;
};

#endif
