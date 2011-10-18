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

#include "fwfreader.h"
#include "conversion.h"
#include <cassert>
#include <iostream>
#include <iomanip>
#include <cstring>
#include <cassert>

FWFReader::FWFReader(const std::string& filename, unsigned int buffersize, unsigned int nlines) :
  filename_(filename), stream_(filename_.c_str(), std::ios_base::in|std::ios::binary), linesize_(determine_linesize(filename)),
  buffersize_(linesize_*buffersize), nlines_(nlines), buffer_(new char[buffersize_]), chars_in_buffer_(0),
  current_index_(0), current_char_(0), line_(new char[linesize_])
{
  line_[linesize_-1] = 0;
  line_[0] = 0;
  if (nlines == 0) nlines_ = determine_nlines();
  reset();
  /*{
    std::cerr << "Opening file '" << filename << "'" << std::endl;
    std::cerr << "  line size = " << linesize_ << std::endl;
    std::cerr << "  number of lines = " << nlines_ << std::endl;
    std::cerr << "  buffer size = " << buffersize << " lines = " << buffersize_ << " characters" << std::endl;
  }*/
}

FWFReader::~FWFReader() {
  if (stream_) stream_.close();
  delete [] buffer_;
  delete [] line_;
}

void FWFReader::reset() {
  stream_.clear();
  stream_.seekg(0, std::ios::beg);
  current_line_ = 0;
  next_block();
}

bool FWFReader::next_line() {
  if (current_index_ >= chars_in_buffer_) next_block();
  if (!current_char_ || !chars_in_buffer_) return false;
  std::strncpy(line_, current_char_, linesize_-1);
  current_char_ += linesize_;
  current_index_ += linesize_;
  current_line_++;
  return true;
}

bool FWFReader::goto_line(unsigned int line) {
  // TODO: check if line is valid?? Depends on how seekg works
  stream_.clear();
  stream_.seekg(line*linesize_, std::ios::beg);
  next_block();
  current_line_ = line;
  return next_line();
}

unsigned int FWFReader::get_current_line() const { 
  return current_line_+1;
}

const char* FWFReader::get_buffer(unsigned int i) const {
  return line_ + start_[i];
}

unsigned int FWFReader::get_length(unsigned int i) const {
  return nchar_[i];
}

const DoubleColumn* FWFReader::add_double_column(unsigned int width) {
  add_column(width);
  return Reader::add_double_column();
}

const IntColumn* FWFReader::add_int_column(unsigned int width) {
  add_column(width);
  return Reader::add_int_column();
}

const StringColumn* FWFReader::add_string_column(unsigned int width) {
  add_column(width);
  return Reader::add_string_column();
}

const FactorColumn* FWFReader::add_factor_column(unsigned int width) {
  add_column(width);
  return Reader::add_factor_column();
}

const IntFactorColumn* FWFReader::add_int_factor_column(unsigned int width) {
  add_column(width);
  return Reader::add_int_factor_column();
}

// ============================================================================
// ============================================================================
// ============================================================================

void FWFReader::add_column(unsigned int start, unsigned int nchar) {
  start_.push_back(start);
  nchar_.push_back(nchar);
}

void FWFReader::add_column(unsigned int nchar) {
  unsigned int start = 0;
  if (start_.size() > 0) {
    start = start_[start_.size()-1] + nchar_[start_.size()-1];
  }
  add_column(start, nchar);
}

void FWFReader::next_block() {
  current_char_ = 0;
  if (stream_.good()) {
    stream_.read(buffer_, buffersize_);
    chars_in_buffer_ = stream_.gcount();
    current_char_ = buffer_;
    current_index_ = 0;
  }
}

unsigned int FWFReader::determine_linesize(const std::string& filename) {
  std::ifstream stream(filename.c_str(), std::ios_base::in|std::ios::binary);
  char c;
  unsigned int linesize = 0;
  while (stream.get(c)) {
    linesize++;
    if (c == '\n') break;
  }
  stream.close();
  return linesize;
}

unsigned int FWFReader::determine_nlines() {
  stream_.clear();
  stream_.seekg(0, std::ios::end);
  unsigned int nbytes = stream_.tellg();
  reset();
  return nbytes/linesize_;
}

