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

#include "csvreader.h" 
#include "conversion.h"
#include "column.h"
#include <cstring>
#include <stdexcept>

CSVReader::CSVReader(const std::string& filename, int sep, unsigned int skip, unsigned int buffer_size) : Reader(),
  filename_(filename), sep_(sep), skip_(skip), buffer_size_(buffer_size), buffer_filled_(1), 
  pointer_(0), current_line_(0)
{
  offset_ = determine_offset(filename, skip_);
  line_size_ = 1024;
  line_ = new char[line_size_];
  file_.open(get_filename().c_str());
  if (file_.fail()) throw std::runtime_error("Failed to open file");
  reset();
  buffer_ = new char[buffer_size_];
  ncolumns_ = determine_ncolumns(get_filename());
  positions_ = new unsigned int[ncolumns_];
  lengths_ = new unsigned int[ncolumns_];

}

CSVReader::~CSVReader() {
  if (file_.is_open()) file_.close();
  if (buffer_) delete[] buffer_;
  if (line_) delete[] line_;
  if (positions_) delete[] positions_;
  if (lengths_) delete[] lengths_;
}

unsigned int CSVReader::nlines() const {
  std::ifstream input(filename_.c_str());
  char buffer[1000000];
  char* bp;
  unsigned int n = 0;
  while (true) {
    input.read(buffer, 1000000);
    unsigned int nread = input.gcount();
    if (nread == 0) break;
    bp = buffer;
    for (unsigned int i = 0; i < nread; ++i, ++bp) {
      if (*bp == '\n') {
	n++;
      }
    }
    if (input.eof()) break;
  }
  return n;
}

void CSVReader::reset() {
  file_.clear();
  file_.seekg(offset_, std::ios::beg);
  buffer_filled_ = 0;
  pointer_ = 0;
  current_line_ = 0; 
}

bool CSVReader::next_line() {
  pointer_++;
  unsigned int column_length = 0;
  unsigned int column_position = 0;
  unsigned int column = 0;
  bool open_quote = false;
  positions_[0] = 0;
  while (true) {
    if (pointer_ >= buffer_filled_) {
      pointer_ = 0;
      file_.read(buffer_, buffer_size_);
      buffer_filled_ = file_.gcount();
      if (buffer_filled_ == 0) {
        if (column == ncolumns_) {
          current_line_++;
          return true;
        } else return false;
      }
    }
    for (; pointer_ < buffer_filled_; ++pointer_) {
      if (open_quote) {
        if (buffer_[pointer_] == '"') {
          open_quote = false;
        } else if (buffer_[pointer_] == '\n') {
          throw(std::runtime_error("Line ended while open quote"));
        } else if (buffer_[pointer_] == '\r') {
          // ignore \r
        } else {
          column_length++;
          if (column_position >= line_size_) resize_line_buffer();
          line_[column_position++] = buffer_[pointer_];
        }
      } else {
        if (buffer_[pointer_] == '"' && column_length == 0) {
          open_quote = true;
        } else if (buffer_[pointer_] == sep_ || buffer_[pointer_] == '\n') {
          lengths_[column] = column_length;
          column++;
          if (buffer_[pointer_] == '\n') {
            current_line_++;
            return column == ncolumns_;
            //return true;
          }
          positions_[column] = column_position;
          if (column >= ncolumns_) throw std::runtime_error("Line has too many columns");
          column_length = 0;
        } else if (buffer_[pointer_] == '\r') {
          // ignore \r
        } else {
          column_length++;
          if (column_position >= line_size_) resize_line_buffer();
          line_[column_position++] = buffer_[pointer_];
        }
      }
    }
  }
  current_line_++;
  return true;
}

bool CSVReader::goto_line(unsigned int line) {
  line++;
  if (current_line_ == line) return true;
  if (current_line_ > line) reset();
  bool result = true;
  while ((current_line_ < line) && result) {
    result = next_line();
  }
  return result;
}

const char* CSVReader::get_buffer(unsigned int i) const {
  return line_ + positions_[i];
}

unsigned int CSVReader::get_length(unsigned int i) const {
  return lengths_[i];
}

const std::string& CSVReader::get_filename() const {
  return filename_;
}

// ============================================================================
// ============================================================================
// ============================================================================

unsigned int CSVReader::determine_offset(const std::string& filename, unsigned int skip) {
  std::ifstream input(filename.c_str());
  unsigned int offset = 0;
  while (skip > 0) {
    int c = input.get();
    offset++;
    if (c == '\n') skip--;
    if (input.eof()) break;
  }
  input.close();
  return offset;
}

unsigned int CSVReader::determine_ncolumns(const std::string& filename) {
  std::ifstream input(filename.c_str());
  input.clear();
  input.seekg(offset_, std::ios::beg);
  int ncolumns = 0;
  bool empty = true;
  while (true) {
    int c = input.get();
    if (c == sep_) {
      empty = false;
      ncolumns++;
    } else if ((!c) || (c == '\n')) {
      if (!empty) ncolumns++;
      break;
    } else {
      empty = false;
    }
    if (input.eof()) break;
  }
  input.close();
  return ncolumns;
}

void CSVReader::resize_line_buffer() {
  unsigned int new_size = line_size_*2;
  if (new_size < 1024) new_size = 1024;
  char* new_line = new char[new_size];
  std::strncpy(new_line, line_, line_size_);
  line_size_ = 0;
  delete[] line_;
  line_size_ = new_size;
  line_ = new_line;
}

