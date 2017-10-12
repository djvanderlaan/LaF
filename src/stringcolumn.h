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

#ifndef stringcolumn_h
#define stringcolumn_h

#include "column.h"
#include <string>

class StringColumn : public Column {
  public:
    StringColumn(const Reader* reader, unsigned int column);
    ~StringColumn();

    void set_trim(bool trim);
    bool get_trim() const;

    double get_double() const {
      return get_value().size();
    }
    int get_int() const {
      return get_value().size();
    }

    std::string get_value() const;

    virtual void assign() {
      v[index] = get_value();
    }

    virtual void init(Rcpp::List::Proxy proxy) {
      v = proxy;
      index = 0;
    }

    virtual void next() {
      ++index;
    }

  private:
    bool trim_;
    Rcpp::CharacterVector v;
    int index;
};

#endif

