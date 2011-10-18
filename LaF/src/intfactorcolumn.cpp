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

#include "intfactorcolumn.h"
#include "reader.h"
#include "conversion.h"

IntFactorColumn::IntFactorColumn(const Reader* reader, unsigned int column) :
  Column(reader, column)
{ }

IntFactorColumn::~IntFactorColumn() {
}

int IntFactorColumn::get_value() const {
  const char*  buffer = reader_->get_buffer(column_);
  unsigned int length = reader_->get_length(column_);
  try {
    if (length == 0 || all_chars_equal(buffer, length, ' ')) return NA_INTEGER;
    int value = strtoint(buffer, length);
    LevelMap::const_iterator p = map_.find(value);
    if (p == map_.end()) return NA_INTEGER; //TODO: throw error?
    return p->second.first;
  } catch(const std::exception& e) {
    std::ostringstream message;
    message << "Conversion to int failed; line=" << reader_->get_current_line()-1
      << "; column=" << column_ 
      << "; string='" << std::string(buffer, length) << "'";
    throw std::runtime_error(message.str());
  }
}

void IntFactorColumn::set_level(int value, const std::string& label) {
  LevelMap::iterator p = map_.find(value);
  if (p == map_.end()) {
    std::cout << "Adding level: '" << value << "' '" << label << "'" << std::endl;
    int level = map_.size() + 1;
    map_[value] = LevelLabel(level, label);
  } else {
    std::cout << "Modifying level: '" << value << "' '" << label << "'" << std::endl;
    p->second.second = label;
  }
}

void IntFactorColumn::clear_levels() {
  map_.clear();
}

unsigned int IntFactorColumn::nlevels() const {
  return map_.size();
}
 
unsigned int IntFactorColumn::get_level(unsigned int i) const {
  for (LevelMap::const_iterator p = map_.begin(); p != map_.end(); ++p) {
    if (p->second.first == i) return p->first;
  }
  return 0;
}
 
std::string IntFactorColumn::get_label(unsigned int i) const {
  for (LevelMap::const_iterator p = map_.begin(); p != map_.end(); ++p) {
    if (p->second.first == i) return p->second.second;
  }
  return "";
}
 
