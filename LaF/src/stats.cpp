/*
Copyright 2011-2012 Jan van der Laan

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

#include <iostream>
#include <iomanip>

//TEST
bool isna(double v) {
  return R_IsNA(v);
}
bool isna(int v) {
  return v == NA_INTEGER;
}

// =======================================================================================
// Iterator template.

template<class T> 
SEXP iterate_column(Reader* reader, Rcpp::IntegerVector columns) {
  // initialize result
  int ncolumns = columns.size();
  std::vector<T> stats(ncolumns);
  // get reader
  if (reader) {
    // start reading
    reader->reset();
    while (reader->next_line()) {
      for (int i = 0; i < ncolumns; ++i) {
        Column* column = reader->get_column(columns[i]);
        stats[i].update(column);
      }
    }
  }
  // close up
  std::vector<SEXP> result;
  for (unsigned int i = 0; i < stats.size(); ++i) {
      result.push_back(stats[i].result());
  }
  return(Rcpp::wrap(result));
}

// =======================================================================================
// COLSUM/COLMEAN

class Sum {
  public:
    Sum() : sum_(0.0), n_(0.0), missing_(0) {};

    void update(Column* column) {
      double value = column->get_double();
      if (isna(value)) missing_++;
      else {
        sum_ += value;
        n_++;
      }
    }

    SEXP result() {
      return Rcpp::List::create(Rcpp::Named("sum") = Rcpp::wrap(sum_),
        Rcpp::Named("n") = Rcpp::wrap(n_),
        Rcpp::Named("missing") = Rcpp::wrap(missing_));
    }

    double sum_;
    double n_;
    int missing_;
};

RcppExport SEXP colsum(SEXP p, SEXP r_columns) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  return iterate_column<Sum>(reader, r_columns);
END_RCPP
} 

// =======================================================================================
// COLFREQ

class Freq {
  public:
    Freq() : missing_(0) {};

    void update(Column* column) {
      int value = column->get_int();
      if (isna(value)) missing_++;
      else table_[value] = table_[value] + 1;
    }

    SEXP result() {
      std::vector<int> value;
      std::vector<int> count;
      for (std::map<int, int>::const_iterator p = table_.begin(); p != table_.end(); ++p) {
        value.push_back(p->first);
        count.push_back(p->second);
      }
      return Rcpp::List::create(Rcpp::Named("value") = Rcpp::wrap(value),
        Rcpp::Named("count") = Rcpp::wrap(count),
        Rcpp::Named("missing") = Rcpp::wrap(missing_));
    }

    std::map<int, int> table_;
    int missing_;
};

RcppExport SEXP colfreq(SEXP p, SEXP r_columns) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  return iterate_column<Freq>(reader, r_columns);
END_RCPP
} 

// =======================================================================================
// RANGE

class Range {
  public:
    Range() : first_(true), min_(0.0), max_(0.0), missing_(0) {};

    void update(Column* column) {
      double value = column->get_double();
      if (isna(value)) missing_++;
      else if (first_) {
        min_ = value;
        max_ = value;
        first_ = false;
      } else if (value < min_) {
        min_ = value;
      } else if (value > max_) {
        max_ = value;
      }
    }

    SEXP result() {
      if (first_) {
        min_ = NA_REAL;
        max_ = NA_REAL;
      }
      return Rcpp::List::create(Rcpp::Named("min") = Rcpp::wrap(min_),
        Rcpp::Named("max") = Rcpp::wrap(max_),
        Rcpp::Named("missing") = Rcpp::wrap(missing_));
    }

    bool first_;
    double min_;
    double max_;
    int missing_;
};

RcppExport SEXP colrange(SEXP p, SEXP r_columns) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  return iterate_column<Range>(reader, r_columns);
END_RCPP
} 

// =======================================================================================
// COLNMISSING

class NMissing {
  public:
    NMissing() : missing_(0) {};

    void update(Column* column) {
      int value = column->get_int();
      if (isna(value)) missing_++;
    }

    SEXP result() {
      return Rcpp::List::create(Rcpp::Named("missing") = Rcpp::wrap(missing_));
    }

    int missing_;
};

RcppExport SEXP colnmissing(SEXP p, SEXP r_columns) {
BEGIN_RCPP
  Rcpp::IntegerVector pv(p);
  Reader* reader = ReaderManager::instance()->get_reader(pv[0]);
  return iterate_column<NMissing>(reader, r_columns);
END_RCPP
}

