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

#ifndef csvreader_h
#define csvreader_h

#include "reader.h"
#include <fstream>
#include <string>

class CSVReader : public Reader {
  public:
    CSVReader(const std::string& filename, int sep = ',', unsigned int buffer_size = 1E5);
    virtual ~CSVReader();
    
    unsigned int nlines() const;

    void reset();
    bool next_line();
    bool goto_line(unsigned int line);

    unsigned int get_current_line() const { return current_line_+1;};

    const char* get_buffer(unsigned int i) const;
    unsigned int get_length(unsigned int i) const;

    const std::string& get_filename() const;

  protected:
    unsigned int determine_ncolumns(const std::string& filename);

  private:
    // file
    std::string filename_;
    int sep_;
    std::fstream file_;
    unsigned int ncolumns_;
    // buffer
    char* buffer_;
    unsigned int buffer_size_;
    unsigned int buffer_filled_;
    unsigned int pointer_;

    // line buffer
    void resize_line_buffer();
    unsigned int line_size_;
    char* line_;
    unsigned int* positions_;
    unsigned int* lengths_;
    unsigned int current_line_;
};

#endif
