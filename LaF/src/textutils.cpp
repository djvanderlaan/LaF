/*
Copyright 2012 Jan van der Laan

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

#include <Rcpp.h>
#include <fstream>
#include <string>
#include <vector>

RcppExport SEXP nlines(SEXP r_filename) {
BEGIN_RCPP
  Rcpp::CharacterVector filenamev(r_filename);
  std::string filename = static_cast<char*>(filenamev[0]);
  std::ifstream input(filename.c_str(), std::ios::in|std::ios::binary);
  char buffer[1000000];
  char* bp;
  unsigned int n = 0;
  bool incomplete_line = false;
  while (true) {
    input.read(buffer, 1000000);
    unsigned int nread = input.gcount();
    if (nread == 0) break;
    bp = buffer;
    for (unsigned int i = 0; i < nread; ++i, ++bp) {
      if (*bp == '\n') {
        incomplete_line = false;
	n++;
      } else {
        incomplete_line = true;
      }
    }
    if (input.eof()) break;
  }
  if (incomplete_line) n++;
  return Rcpp::wrap(n);
END_RCPP
}

std::vector<std::string> get_line(const std::string& filename, 
    std::vector<int> line_numbers) {
  std::ifstream input(filename.c_str(), std::ios::in|std::ios::binary);
  char buffer[1000000];
  char* bp;
  int n = 0;
  unsigned int line_index = 0;
  int line_number = line_numbers[line_index];
  std::vector<std::string> result;
  std::string current_line = std::string();
  // start reading until line number
  bool stop = false;
  while (!stop) {
    input.read(buffer, 1000000);
    unsigned int nread = input.gcount();
    if (nread == 0) break;
    bp = buffer;
    for (unsigned int i = 0; i < nread; ++i, ++bp) {
      if (*bp == '\n') {
        if (n == line_number) {
          result.push_back(current_line);
          line_index++;
          if (line_index >= line_numbers.size()) {
            stop = true;
            break;
          }
          line_number = line_numbers[line_index];
          current_line = std::string();
        }
        n++;
      } else {
        if (n == line_number) current_line += *bp;
      }
    }
    if (input.eof()) break;
  }
  return result;
}

std::vector<std::string> get_lines(const std::string& filename,
    const std::vector<unsigned int>& line_numbers) {
  
  std::vector<std::string> lines;
  std::ifstream input(filename.c_str(), std::ios::in|std::ios::binary);
  char buffer[1000000];
  char* bp;
  unsigned int n = 0;
  unsigned int current_i = 0;
  unsigned int current_n = line_numbers[current_i];
  std::string current_line = std::string();
  // start reading until line number
  while (true) {
    input.read(buffer, 1000000);
    unsigned int nread = input.gcount();
    if (nread == 0) break;
    bp = buffer;
    for (unsigned int i = 0; i < nread; ++i, ++bp) {
      if (*bp == '\n') {
        if (current_line != "") {
          lines.push_back(current_line);
          current_i++;
          if (current_i >= line_numbers.size()) current_i--;
          current_n = line_numbers[current_i];
          current_line = std::string();
        }
        n++;
      } else {
        if (n == current_n) {
          current_line += *bp;
        }
      }
    }
    if (input.eof()) break;
  }
  return(lines);
}

RcppExport SEXP r_get_line(SEXP r_filename, SEXP r_line_numbers) {
BEGIN_RCPP
  Rcpp::CharacterVector filenamev(r_filename);
  std::string filename = static_cast<char*>(filenamev[0]);
  std::vector<int> line_numbers = Rcpp::as< std::vector<int> >(r_line_numbers);
  std::vector<std::string> result = get_line(filename, line_numbers);
  return Rcpp::wrap(result);
END_RCPP
}
