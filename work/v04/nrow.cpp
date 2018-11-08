#include "csvreader.h"
#include "eventhandlercountrows.h"

#include <iostream>
#include <iomanip>
#include <chrono>

int main(int argc, char* argv[]) {
  // Parse arguments
  if (argc < 2) std::cerr << "Missing filename" << std::endl;
  std::string filename = argv[1];
  std::cout << filename << std::endl;
  // Start time measurement
  auto t1 = std::chrono::high_resolution_clock::now();
  // Open file
  EventHandlerCountRows handler;
  CSVReader<EventHandlerCountRows> reader(filename, handler);
  // Parse
  reader.parse();
  // Stop time measurement
  auto t2 = std::chrono::high_resolution_clock::now();
  double tdif = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
  // Show results
  std::cout << "#rows = " << handler.nrow() << std::endl;
  std::cout << "#cols = " << handler.ncol() << std::endl;
  std::cout << "Elapsed time: " << tdif/1000.0 << " seconds." << std::endl;
  return 0;
}

