/*
Copyright 2017 Jan van der Laan

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
  
extern "C" {
  SEXP laf_open_csv(SEXP r_filename, SEXP r_types, SEXP r_sep, SEXP r_dec, 
    SEXP r_trim, SEXP r_skip, SEXP r_ignore_failed_conversion);
  SEXP laf_open_fwf(SEXP r_filename, SEXP r_types, SEXP r_widths, SEXP r_dec,
    SEXP r_trim, SEXP r_ignore_failed_conversion);
  SEXP laf_close(SEXP p);
  SEXP laf_reset(SEXP p);
  SEXP laf_goto_line(SEXP p, SEXP r_line);
  SEXP laf_nrow(SEXP p);
  SEXP laf_current_line(SEXP p);
  SEXP laf_next_block(SEXP p, SEXP r_nlines, SEXP r_columns, SEXP r_result);
  SEXP laf_read_lines(SEXP p, SEXP r_lines, SEXP r_columns, SEXP r_result);
  SEXP laf_levels(SEXP p, SEXP r_column);
  SEXP colsum(SEXP p, SEXP r_columns);
  SEXP colfreq(SEXP p, SEXP r_columns);
  SEXP colrange(SEXP p, SEXP r_columns);
  SEXP colnmissing(SEXP p, SEXP r_columns);
  SEXP nlines(SEXP r_filename);
  SEXP r_get_line(SEXP r_filename, SEXP r_line_numbers);
}



