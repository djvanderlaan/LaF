
#include "csvreader.h"

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
  CSVReader reader(filename);
  // Add columns
  //IntColumn column;
  DoubleColumn column;
  for (int i = 0; i < 7; ++i) reader.add_column(&column);
  //PrintColumn column;
  //for (int i = 0; i < 3; ++i) reader.add_column(&column);
  // Parse
  reader.parse();
  // Stop time measurement
  auto t2 = std::chrono::high_resolution_clock::now();
  double tdif = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
  // Show results
  //std::cout << column.sum() << std::endl;
  std::cout << "Elapsed time: " << tdif/1000.0 << " seconds." << std::endl;
  return 0;
}

