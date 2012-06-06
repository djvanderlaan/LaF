
#include <iostream>
#include <iomanip>
#include <random>
#include <stdlib.h>

int main(int argc, char** argv) {
  unsigned int nsim = 20;
  unsigned int ncol = 5;
  if (argc > 1) {
    nsim = std::atoi(argv[1]);
    if (argc > 2) {
      ncol = std::atoi(argv[2]);
    }
  }

  // create random generator
  std::random_device rd;
  std::mt19937 gen(rd());
  // create random distributions
  std::uniform_int_distribution<> binom(0, 1);
  std::uniform_int_distribution<> uniform_int(0, 99);
  std::normal_distribution<> normal(0, 1);
  std::lognormal_distribution<> lognormal(0, 1);
  // create data
  for(int i = 0; i < nsim; ++i) {

    // id
    std::cout << i;
    
    // gender
    char gender = binom(gen) > 0 ? 'M' : 'F';
    std::cout << ';' << gender;

    // age
    std::cout << ';' << uniform_int(gen);

    // int
    for (unsigned int j = 0; j < ncol; ++j) 
      std::cout << ';' << uniform_int(gen);

    // normal
    for (unsigned int j = 0; j < ncol; ++j) 
      std::cout << ';' << std::setprecision(2) << normal(gen);

    // log-normal
    for (unsigned int j = 0; j < ncol; ++j) 
      std::cout << ';' << std::setprecision(2) << lognormal(gen);

    std::cout << '\n';
  }
  return 0;
}
