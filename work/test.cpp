#include <iostream>
#include <iomanip>
#include <cmath>

#include "conversion.h"

int test_conversion_of_double(const std::string& str, double expected, bool expect_err = false,
    double precision = 1E-15) {
  std::cout << "Conversion of '" << str << "' to double: ";
  bool err;
  double result = f_atod(str.c_str(), str.length(), &err);
  if (err) {
    std::cout << "FAILED (" << result << ")";
  } else {
    std::cout << result;
  }
  if (err) {
    if (expect_err) {
      std::cout << "\t\tPASS\n";
      return 0;
    } else {
      std::cout << "\t\tFAIL\n";
      return 1;
    }
  } else {
    if (std::abs(expected - result) <= precision) { 
      std::cout << "\t\tPASS\n";
      return 0;
    } else {
      std::cout << "\t\tFAIL\n";
      return 1;
    }
  } 
}

int test_conversion_of_int(const std::string& str, int expected, bool expect_err = false) {
  std::cout << "Conversion of '" << str << "' to double: ";
  bool err;
  int result = atoif(str.c_str(), str.length(), &err);
  if (err) {
    std::cout << "FAILED (" << result << ")";
  } else {
    std::cout << result;
  }
  if (err) {
    if (expect_err) {
      std::cout << "\t\tPASS\n";
      return 0;
    } else {
      std::cout << "\t\tFAIL\n";
      return 1;
    }
  } else {
    if (expected == result) { 
      std::cout << "\t\tPASS\n";
      return 0;
    } else {
      std::cout << "\t\tFAIL\n";
      return 1;
    }
  } 
}


int main(int argc, char* argv[]) {
  int nfail = 0;
  nfail += test_conversion_of_double("1.4", 1.4);
  nfail += test_conversion_of_double("-1.4", -1.4);
  nfail += test_conversion_of_double("1004", 1004.0);
  nfail += test_conversion_of_double("-1004", -1004.0);
  nfail += test_conversion_of_double(".4", 0.4);
  nfail += test_conversion_of_double("-.4", -0.4);
  nfail += test_conversion_of_double("1E4", 1E4);
  nfail += test_conversion_of_double("-1E4", -1E4);
  nfail += test_conversion_of_double("1.1234E-3", 1.1234E-3);
  nfail += test_conversion_of_double("-1.1234E-3", -1.1234E-3);
  nfail += test_conversion_of_double("test", 0.0, true);
  nfail += test_conversion_of_double("-test", 0.0, true);
  nfail += test_conversion_of_double("1test", 0.0, true);
  nfail += test_conversion_of_double("-1test", 0.0, true);
  nfail += test_conversion_of_double("", 0.0);
  nfail += test_conversion_of_double("-", 0.0, true);

  nfail += test_conversion_of_int("1", 1);
  nfail += test_conversion_of_int("100", 100);
  nfail += test_conversion_of_int("", 0);
  nfail += test_conversion_of_int("foo", 0, true);
  nfail += test_conversion_of_int("-1", -1);
  nfail += test_conversion_of_int("-100", -100);
  nfail += test_conversion_of_int("-", 0, true);
  nfail += test_conversion_of_int("-foo", 0, true);
  nfail += test_conversion_of_int("010", 10);

  std::cout << "\n FAILED: " << nfail << "\n";
  return 0;
}

