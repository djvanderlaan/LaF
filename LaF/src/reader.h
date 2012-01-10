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

#ifndef reader_h
#define reader_h

#include "intcolumn.h"
#include "doublecolumn.h"
#include "stringcolumn.h"
#include "factorcolumn.h"
#include <vector>

class Reader {
  public:
    Reader();
    virtual ~Reader();

    virtual unsigned int nlines() const = 0;

    virtual void reset() = 0;
    virtual bool next_line() = 0;
    virtual bool goto_line(unsigned int line) = 0;

    virtual unsigned int get_current_line() const = 0;

    virtual const char* get_buffer(unsigned int i) const = 0;
    virtual unsigned int get_length(unsigned int i) const = 0;

    const DoubleColumn* add_double_column();
    const IntColumn* add_int_column();
    const StringColumn* add_string_column();
    const FactorColumn* add_factor_column();

    const std::vector<Column*>& get_columns() const;
    Column* get_column(unsigned int i) const;

    void set_decimal_seperator(char seperator);
    char get_decimal_seperator() const;

    void set_trim(bool trim);
    bool get_trim() const; 

  private:
    std::vector<Column*> columns_;
    char decimal_seperator_;
    bool trim_;
};

#endif
