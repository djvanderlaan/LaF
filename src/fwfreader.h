/*
Copyright 2011-2017 Jan van der Laan

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

#ifndef FWFREADER_H
#define FWFREADER_H

#include "reader.h" 
#include <fstream>
#include <string>
#include <vector>

class FWFReader : public Reader
{
  public:
    FWFReader(const std::string& filename, unsigned int buffersize = 1024, unsigned int nlines = 0);
    ~FWFReader();
    
    unsigned int line_size() const { return linesize_;}
    unsigned int nlines() const { return nlines_;}
    
    void reset();
    bool next_line();
    bool goto_line(unsigned int line);

    unsigned int get_current_line() const;

    const char* get_buffer(unsigned int i) const;
    unsigned int get_length(unsigned int i) const;

    const DoubleColumn* add_double_column(unsigned int width);
    const IntColumn* add_int_column(unsigned int width);
    const StringColumn* add_string_column(unsigned int width);
    const FactorColumn* add_factor_column(unsigned int width);

  protected:
    void add_column(unsigned int start, unsigned int nchar);
    void add_column(unsigned int nchar);

    void next_block();
    
    unsigned int determine_linesize(const std::string& filename);
    unsigned int determine_nlines();
    
  private:
    std::string filename_;
    std::ifstream stream_;
    std::ios::pos_type offset_ = 0;
    
    unsigned int linesize_;
    unsigned int buffersize_;
    unsigned int nlines_;
    unsigned int current_line_;
    
    char* buffer_;
    unsigned int chars_in_buffer_;
    unsigned int current_index_;
    char* current_char_;
    
    char* line_;

    std::vector<unsigned int> start_;
    std::vector<unsigned int> nchar_;
};
#endif
