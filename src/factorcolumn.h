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

#ifndef factorcolumn_h
#define factorcolumn_h

#include "column.h"
#include <string>
#include <map>

class FactorColumn : public Column {
  public:
    FactorColumn(const Reader* reader, unsigned int column);
    ~FactorColumn();

    double get_double() const {
      int value = get_value();
      if (value == NA_INTEGER) return NA_REAL;
      return value;
    }
    int get_int() const {
      return get_value();
    }

    void set_trim(bool trim);
    bool get_trim() const;

    int get_value() const;

    const std::map<std::string, int>& get_levels() const;

    virtual void assign() {
      (*pv) = get_value();
    }

    virtual void init(Rcpp::List::Proxy proxy) {
      v = proxy;
      pv = v.begin();
    }

    virtual void next() {
      ++pv;
    }
    
  private:
    bool trim_;
    mutable std::map<std::string, int> levels_;
    Rcpp::IntegerVector v;
    int* pv;
};

#endif

