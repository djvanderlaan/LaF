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

#include "stringcolumn.h"
#include "reader.h"
#include "conversion.h"

StringColumn::StringColumn(const Reader* reader, unsigned int column) :
  Column(reader, column)
{ }

StringColumn::~StringColumn() {
}

std::string StringColumn::get_value() const {
  return std::string(reader_->get_buffer(column_), reader_->get_length(column_));
}


