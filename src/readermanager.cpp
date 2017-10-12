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

#include "readermanager.h"
#include "reader.h"
#include <vector>

// ==============================================================================
// ==============================================================================
// ==============================================================================


ReaderManager* ReaderManager::instance_ = 0;

ReaderManager* ReaderManager::instance() {
  if (instance_ == 0) {
    instance_ = new ReaderManager();
  }
  return instance_;
}

ReaderManager::~ReaderManager() {
  for (std::vector<Reader*>::iterator p = readers_.begin(); p != readers_.end(); ++p) {
    delete *p;
  }
  instance_ = 0;
}

int ReaderManager::new_reader(Reader* reader) {
  readers_.push_back(reader);
  return readers_.size()-1;
}

Reader* ReaderManager::get_reader(int readerindex) {
  if (readerindex < 0) return 0;
  if (readerindex >= static_cast<int>(readers_.size())) return 0;
  return readers_.at(readerindex);
}

void ReaderManager::close_reader(int readerindex) {
  if (readerindex >= 0) {
    Reader* reader = get_reader(readerindex);
    if (reader) {
      delete reader;
      readers_[readerindex] = 0;
    } else {
      // reader does not exist
    }
  } else {
    // reader already deleted
  }
}


ReaderManager::ReaderManager() {
}

