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

#include "reader.h" 

Reader::Reader() : decimal_seperator_('.'), trim_(false), 
  ignore_failed_conversion_(false) {
}

Reader::~Reader() {
  for (std::vector<Column*>::iterator p = columns_.begin(); p != columns_.end(); ++p) 
    delete *p;
}

const DoubleColumn* Reader::add_double_column() {
  DoubleColumn* column = new DoubleColumn(this, columns_.size(), 
    ignore_failed_conversion_);
  column->set_decimal_seperator(decimal_seperator_);
  columns_.push_back(column);
  return column;
}

const IntColumn* Reader::add_int_column() {
  IntColumn* column = new IntColumn(this, columns_.size(),
    ignore_failed_conversion_);
  columns_.push_back(column);
  return column;
}

const StringColumn* Reader::add_string_column() {
  StringColumn* column = new StringColumn(this, columns_.size());
  column->set_trim(trim_);
  columns_.push_back(column);
  return column;
}
const FactorColumn* Reader::add_factor_column() {
  FactorColumn* column = new FactorColumn(this, columns_.size());
  column->set_trim(trim_);
  columns_.push_back(column);
  return column;
}

const std::vector<Column*>& Reader::get_columns() const {
  return columns_;
}

Column* Reader::get_column(unsigned int i) const {
  return columns_[i];
}

void Reader::set_decimal_seperator(char seperator) {
  decimal_seperator_ = seperator;
}

char Reader::get_decimal_seperator() const {
  return decimal_seperator_;
}

void Reader::set_trim(bool trim) {
  trim_ = trim;
}

bool Reader::get_trim() const {
  return trim_;
}

void Reader::set_ignore_failed_conversion(bool ignore) {
  ignore_failed_conversion_ = ignore;
}

bool Reader::get_ignore_failed_conversion() const {
  return ignore_failed_conversion_;
}
