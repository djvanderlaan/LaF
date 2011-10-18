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

#include "file.h"
#include <fstream>

int determine_linebreak(const std::string& filename) {
  std::fstream file(filename.c_str(), std::ios_base::in|std::ios_base::binary);
  char c;
  while (file.get(c)) {
    if (c == '\n') {
      return 1;
    }
    if (c == '\r') {
      if (file.get(c)) {
        if (c == '\n') return 2;
      }
      return 3;
    }

  }
  return 0;
}
