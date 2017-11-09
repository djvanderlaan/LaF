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

#include "intcolumn.h"
#include "reader.h"
#include "conversion.h"

IntColumn::IntColumn(const Reader* reader, unsigned int column,
    bool ignore_failed_conversion) :
  Column(reader, column, ignore_failed_conversion)
{ }

IntColumn::~IntColumn() {
}

int IntColumn::get_value() const {
  const char*  buffer = reader_->get_buffer(column_);
  unsigned int length = reader_->get_length(column_);
  try {
    if (length == 0 || all_chars_equal(buffer, length, ' ')) return NA_INTEGER;
    return strtoint(buffer, length);
  } catch(const std::exception& e) {
    if (ignore_failed_conversion_) return NA_INTEGER;
    std::ostringstream message;
    message << "Conversion to int failed; line=" << reader_->get_current_line()-1
      << "; column=" << column_ 
      << "; string='" << std::string(buffer, length) << "'";
    throw std::runtime_error(message.str());
  }
}


