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

#include "factorcolumn.h"
#include "reader.h"
#include "conversion.h"

FactorColumn::FactorColumn(const Reader* reader, unsigned int column) :
  Column(reader, column), trim_(false)
{ }

FactorColumn::~FactorColumn() {
}

void FactorColumn::set_trim(bool trim) {
  trim_ = trim;
}

bool FactorColumn::get_trim() const {
  return trim_;
}
    
int FactorColumn::get_value() const {
  const char*  buffer = reader_->get_buffer(column_);
  unsigned int length = reader_->get_length(column_);
  std::string value = chartostring(buffer, length, trim_);
  if (value.length() == 0) return NA_INTEGER;
  //if (length == 0 || all_chars_equal(buffer, length, ' ')) return NA_INTEGER;
  //if (length == 0) return NA_INTEGER;
  //std::string value(buffer, length);
  if (levels_[value] == 0) {
    levels_[value] = levels_.size();
  }
  return levels_[value];
}

const std::map<std::string, int>& FactorColumn::get_levels() const {
  return levels_;
}

