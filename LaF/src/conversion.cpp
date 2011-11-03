#include "conversion.h"
#include <cmath>

inline int chartoint(char c) {
  switch (c) {
    case '0': return 0;
    case '1': return 1;
    case '2': return 2;
    case '3': return 3;
    case '4': return 4;
    case '5': return 5;
    case '6': return 6;
    case '7': return 7;
    case '8': return 8;
    case '9': return 9;
    default : throw ConversionError();
  }
}

int strtoint(const char* str, unsigned int nchar) {
  if (nchar < 1) throw ConversionError();
  const char* c = str + (nchar-1);
  int n = 1;
  int result = 0;
  int sign = 1;
  bool rtrim = true;
  bool ltrim = false;
  for (unsigned int i = 0; i < nchar; ++i, --c) {
    if (*c == ' ') {
      if (!rtrim) ltrim = true;
    } else if (*c == '-') {
      if (rtrim | ltrim) throw ConversionError();
      sign = -1;
      ltrim = true;
      rtrim = false;
    } else if (*c == '+') {
      if (rtrim | ltrim) throw ConversionError();
      ltrim = true;
      rtrim = false;
    } else {
      if (ltrim) throw ConversionError();
      result += n*chartoint(*c);
      n *= 10;
      rtrim = false;
    }
  }
  if (n == 1) throw ConversionError();
  return sign*result;
}

bool all_chars_equal(const char* str, unsigned int n, char c) {
  for (unsigned int i = 0; i < n; ++i, ++str) {
    if ((*str) != c) return false;
  }
  return true;
}

// ============================================================================
// ===                 CONVERSION FROM STRING TO DOUBLE                    ====
// ============================================================================

inline double read_sign(const char** c, unsigned int* i, unsigned int nchar) {
  for (; *i < nchar; ++*i, ++*c) {
    if (**c == '-') {
      ++*c; ++*i;
      return -1.0;
    }
    if (**c != ' ') return 1.0;
  }
  throw ConversionError();
} 

void check_remainder(const char** c, unsigned int* i, unsigned int nchar) {
  for (; *i < nchar; ++*i, ++*c) {
    if (**c != ' ') throw ConversionError();
  }
}

inline int read_before_decimal(double* part1, const char** c, unsigned int* i, unsigned int nchar, char dec) {
  double n1 = 1.0;
  double result1 = 0.0;
  int result = 0;
  for (; *i < nchar; ++*i, ++*c) {
    if (**c == dec) {
      ++*c; ++*i;
      result = 1;
      break;
    }
    if (**c == 'E' || **c == 'e') {
      ++*c; ++*i;
      result = 2;
      break;
    }
    if (**c == ' ') {
      check_remainder(c, i, nchar);
      break;
    }
    result1 += chartoint(**c) * n1;
    n1 *= 0.1;
  }
  *part1 = result1/n1*0.1;
  return result;
}

inline int read_after_decimal(double* part2, const char** c, unsigned int* i, unsigned int nchar, char dec) {
  double n2 = 0.1;
  *part2 = 0.0;
  int result = 0;
  for (; *i < nchar; ++*i, ++*c) {
    if (**c == ' ') {
      check_remainder(c, i, nchar);
      break;
    }
    if (**c == 'E' || **c == 'e') {
      ++*c; ++*i;
      result = 2;
      break;
    }
    *part2 += chartoint(**c) * n2;
    n2 *= 0.1;
  }
  return result;
}

inline double read_exponent(const char** c, unsigned int* i, unsigned int nchar) {
  int e = strtoint(*c, nchar-*i);
  *i = nchar;
  return pow(10, e);
}

double strtodouble(const char* str, unsigned int nchar, char dec) {
  if (nchar < 1) throw ConversionError();
  // initialisation
  const char*  c        = str;
  unsigned int i        = 0;
  double before_decimal = 0.0;
  double after_decimal  = 0.0;
  double exponent       = 1.0;
  // start reading
  double sign = read_sign(&c, &i, nchar); 
  int    next = read_before_decimal(&before_decimal, &c, &i, nchar, dec); 
  switch (next) {
    case 1:
      next = read_after_decimal(&after_decimal, &c, &i, nchar, dec); 
      if (next != 2) break;
    case 2:
      exponent = read_exponent(&c, &i, nchar); 
  }
  // calculate end result
  return sign * exponent*(before_decimal + after_decimal);
}

