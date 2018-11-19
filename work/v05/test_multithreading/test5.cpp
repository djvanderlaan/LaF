#include "buffer3.h"
#include <chrono>
#include <iostream>
#include <iomanip>

int main(int argc, char* argv[]) {
  // Parse arguments
  if (argc < 2) std::cerr << "Missing filename" << std::endl;
  std::string filename = argv[1];
  std::cout << filename << std::endl;
  // Start time measurement
  auto t1 = std::chrono::high_resolution_clock::now();
  // Parse
  Buffer buffer(filename);
  std::size_t nlines = 0;
  while (char c = buffer.next()) {
    if (c == '\n') ++nlines;
  }
  // Stop time measurement
  auto t2 = std::chrono::high_resolution_clock::now();
  double tdif = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
  // Show results
  std::cout << "#lines = " << nlines << std::endl;
  std::cout << "Elapsed time: " << tdif/1000.0 << " seconds." << std::endl;
  return 0;
}

