/*
Copyright 2011 Jan van der Laan

This file is part of LaF.

LaF is free software: you can redistribute it and/or modify it under the terms
of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

LaF is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
LaF.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "conversion.h"

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

// TODO: because of the limited floating point accuracy of the calculations performed in the
// function it is possible to have small (E-15) errors when writing and reading again
double strtodouble(const char* str, unsigned int nchar, char dec) {
  if (nchar < 1) throw ConversionError();
  const char* c = str + (nchar-1);
  double n = 1.0;
  double result = 0.0;
  double fafter = 1.0;
  double sign = 1;
  bool after = true;
  bool rtrim = true;
  bool ltrim = false;
  for (unsigned int i = 0; i < nchar; ++i, --c) {
    if (*c == ' ') {
      if (!rtrim) ltrim = true;
    } else if (*c == dec) {
      if (rtrim || ltrim || !after) throw ConversionError();
      after = false;
    } else if (*c == '-') {
      if (rtrim | ltrim) throw ConversionError();
      sign = -1;
      ltrim = true;
      rtrim = false;
    } else {
      if (ltrim) throw ConversionError();
      result += n*chartoint(*c);
      n *= 10;
      rtrim = false;
      if (after) fafter *= 10;
    }
  }
  if (n == 1) throw ConversionError();
  if (after) fafter = 1;
  return sign*static_cast<double>(result)/static_cast<double>(fafter);
}

bool all_chars_equal(const char* str, unsigned int n, char c) {
  for (unsigned int i = 0; i < n; ++i, ++str) {
    if ((*str) != c) return false;
  }
  return true;
}

