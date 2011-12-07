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

#ifndef column_h
#define column_h

#include <Rcpp.h>

class Reader;

class Column 
{
  public:
    Column(const Reader* reader, unsigned int column);
    ~Column();

    virtual double get_double() const = 0; 
    virtual int get_int() const = 0; 

    virtual void assign() = 0;
    virtual void init(Rcpp::List::Proxy proxy) = 0;
    virtual void next() = 0;

  protected:
    const Reader* reader_;
    unsigned int column_;
};

#endif
