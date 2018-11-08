#include "dynamicarray.h"

#include <iostream>
#include <iomanip>

int main(int argc, char* argv[]) {
  DynamicArray<int> array{};

  for (int i = 0; i < 1000000; ++i) {
    array.push_back(i);
  }
  array.truncate();


  const int* p = array.data();
  for (int i = 0; i < 10; ++i, ++p) {
    std::cout << (*p) << std::endl;
  }

  return 0;
}
