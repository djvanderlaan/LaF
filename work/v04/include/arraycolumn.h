#ifndef arraycolumns_h
#define arraycolumns_h

#include "columns.h"
#include "dynamicarray.h"

template<typename T>
class ArrayColumn: public Column {
  public:
    ArrayColumn(std::size_t initial_size = 1024) : array_(initial_size) {
    }

    void start_reading() {};

    bool parse(char* str, std::size_t len) {
      bool err; 
      T val = convert<T>(str, len, &err);
      array_.push_back(val);
    };

    void finished_reading() {
      array_.truncate();
    };

    const T* data() const { return array_.data();}
    std::size_t size() const { return array_.size();}

  private:
    DynamicArray<T> array_;
};


#endif
