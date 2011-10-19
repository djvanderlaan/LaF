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

#include "csvreader.h"
#include "fwfreader.h"
#include "readermanager.h"
#include <Rcpp.h>

RcppExport SEXP laf_open_csv(SEXP r_filename, SEXP r_types, SEXP r_sep, SEXP r_dec) {
BEGIN_RCPP
  Rcpp::CharacterVector filenamev(r_filename);
  Rcpp::IntegerVector types(r_types);
  std::string filename = static_cast<char*>(filenamev[0]);
  Rcpp::CharacterVector sepv(r_sep);
  int sep = static_cast<int>(sepv[0][0]);
  Rcpp::CharacterVector decv(r_dec);
  char dec = static_cast<char>(decv[0][0]);
  Rcpp::IntegerVector p = Rcpp::IntegerVector::create(1);
  CSVReader* reader = new CSVReader(filename, sep);
  reader->set_decimal_seperator(dec);
  for (int i = 0; i < types.size(); ++i) {
    if (types[i] == 0) {
      reader->add_double_column();
    } else if (types[i] == 1) {
      reader->add_int_column();
    } else if (types[i] == 2) {
      reader->add_factor_column();
    } else if (types[i] == 3) {
      reader->add_string_column();
    } else if (types[i] == 4) {
      reader->add_int_factor_column();
    }
  }
  p[0] = ReaderManager::instance()->new_reader(reader);
  return p;
END_RCPP
}

RcppExport SEXP laf_open_fwf(SEXP r_filename, SEXP r_types, SEXP r_widths, SEXP r_dec) {
BEGIN_RCPP
  Rcpp::CharacterVector filenamev(r_filename);
  Rcpp::IntegerVector types(r_types);
  Rcpp::IntegerVector widths(r_widths);
  std::string filename = static_cast<char*>(filenamev[0]);
  Rcpp::CharacterVector decv(r_dec);
  char dec = static_cast<char>(decv[0][0]);
  Rcpp::IntegerVector p = Rcpp::IntegerVector::create(1);
  FWFReader* reader = new FWFReader(filename);
  reader->set_decimal_seperator(dec);
  for (int i = 0; i < types.size(); ++i) {
    if (types[i] == 0) {
      reader->add_double_column(widths[i]);
    } else if (types[i] == 1) {
      reader->add_int_column(widths[i]);
    } else if (types[i] == 2) {
      reader->add_factor_column(widths[i]);
    } else if (types[i] == 3) {
      reader->add_string_column(widths[i]);
    } else if (types[i] == 4) {
      reader->add_int_factor_column(widths[i]);
    }
  }
  p[0] = ReaderManager::instance()->new_reader(reader);
  return p;
END_RCPP
}

RcppExport SEXP laf_close(SEXP p) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  ReaderManager::instance()->close_reader(pv[0]);
  pv[0] = -1;
  return pv;
END_RCPP
}

RcppExport SEXP laf_reset(SEXP p) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  if (reader) reader->reset();
  return pv;
END_RCPP
}

RcppExport SEXP laf_goto_line(SEXP p, SEXP r_line) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Rcpp::IntegerVector line(r_line);
  unsigned int l = static_cast<unsigned int>(line[0]);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  if (reader) {
    if (l == 1) {
      reader->reset();
    } else {
      reader->goto_line(l-2);
    }
  }
  return pv;
END_RCPP
}

RcppExport SEXP laf_nrow(SEXP p) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  int nrow = 0;
  if (reader) { 
    nrow = static_cast<int>(reader->nlines());
  }
  // close up
  Rcpp::NumericVector r_nrow(1);
  r_nrow[0] = nrow;
  return r_nrow;
END_RCPP
}

RcppExport SEXP laf_current_line(SEXP p) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  unsigned int current_line = 0;
  if (reader) { 
    current_line = static_cast<int>(reader->get_current_line());
  }
  // close up
  Rcpp::NumericVector r_current_line(1);
  r_current_line[0] = current_line;
  return r_current_line;
END_RCPP
}

RcppExport SEXP laf_next_block(SEXP p, SEXP r_nlines, SEXP r_columns, SEXP r_result) {
BEGIN_RCPP
  // transform from SEXP-types to Rcpp-types
  Rcpp::IntegerVector pv(p);
  Rcpp::IntegerVector columns(r_columns);
  int nlines = Rcpp::IntegerVector(r_nlines)[0];
  unsigned int ncolumns = columns.size();
  Rcpp::DataFrame result(r_result);
  int nread = 0;
  // get reader
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  if (reader) {
    // initialize columns
    for (unsigned int i = 0; i < ncolumns; ++i) {
      Column* column = reader->get_column(columns[i]);
      column->init(result[i]);
    }
    // start reading
    while (reader->next_line()) {
      for (unsigned int i = 0; i < ncolumns; ++i) {
        Column* column = reader->get_column(columns[i]);
	column->assign();
	column->next();
      }
      ++nread;
      if (nread >= nlines) break;
    }
  }
  // close up
  Rcpp::NumericVector r_nread(1);
  r_nread[0] = nread;
  return r_nread;
END_RCPP
}

RcppExport SEXP laf_read_lines(SEXP p, SEXP r_lines, SEXP r_columns, SEXP r_result) {
BEGIN_RCPP
  // transform from SEXP-types to Rcpp-types
  Rcpp::IntegerVector pv(p);
  Rcpp::IntegerVector columns(r_columns);
  Rcpp::IntegerVector lines(r_lines);
  unsigned int ncolumns = columns.size();
  unsigned int nlines = lines.size();
  Rcpp::DataFrame result(r_result);
  int nread = 0;
  // get reader
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  if (reader) {
    // initialize columns
    for (unsigned int i = 0; i < ncolumns; ++i) {
      Column* column = reader->get_column(columns[i]);
      column->init(result[i]);
    }
    // start reading
    for (unsigned int i = 0; i < nlines; ++i) {
      if (static_cast<unsigned int>(lines[i]) == reader->get_current_line()-1) {
        if (reader->next_line()) {
          for (unsigned int j = 0; j < ncolumns; ++j) {
            Column* column = reader->get_column(columns[j]);
            column->assign();
            column->next();
          }
          ++nread;
        }
      } else if (reader->goto_line(lines[i])) {
        for (unsigned int j = 0; j < ncolumns; ++j) {
          Column* column = reader->get_column(columns[j]);
          column->assign();
          column->next();
        }
        ++nread;
      }
    }
  }
  // close up
  Rcpp::NumericVector r_nread(1);
  r_nread[0] = nread;
  return r_nread;
END_RCPP
}

RcppExport SEXP laf_levels(SEXP p, SEXP r_column) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Rcpp::IntegerVector column(r_column);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  std::vector<std::string> levels;
  if (reader) {
    
    const FactorColumn* factor = dynamic_cast<const FactorColumn*>(reader->get_column(column[0]));
    if (factor) {
      const std::map<std::string, int>& levels_map = factor->get_levels();
      for (std::map<std::string, int>::const_iterator p = levels_map.begin(); p != levels_map.end(); ++p) {
        levels.push_back(p->first);
      }
    }
  }
  Rcpp::CharacterVector r_levels(levels.size());
  for (unsigned int i = 0; i < levels.size(); ++i) {
    r_levels[i] = levels[i];
  }
  return r_levels;
END_RCPP
}

RcppExport SEXP laf_set_levels(SEXP p, SEXP r_column, SEXP r_levels, SEXP r_labels) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Rcpp::IntegerVector column(r_column);
  Rcpp::IntegerVector levels(r_levels);
  Rcpp::CharacterVector labels(r_labels);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  if (reader) {
    
    IntFactorColumn* factor = dynamic_cast<IntFactorColumn*>(reader->get_column(column[0]));
    if (factor) {
      for (int i = 0; i < levels.size(); ++i) {
        int level = levels[i];
        std::string label = static_cast<char*>(labels[i]);
        factor->set_level(level, label);
      }
    }
  }
  return r_levels;
END_RCPP
}

