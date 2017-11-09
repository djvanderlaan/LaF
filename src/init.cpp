#include "LaF.h"
#include <R_ext/Rdynload.h>

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}


extern "C" {

  static const R_CallMethodDef r_calldef[] = {
     CALLDEF(laf_open_csv, 7),
     CALLDEF(laf_open_fwf, 6),
     CALLDEF(laf_close, 1),
     CALLDEF(laf_reset, 1),
     CALLDEF(laf_goto_line, 2),
     CALLDEF(laf_nrow, 1),
     CALLDEF(laf_current_line, 1),
     CALLDEF(laf_next_block, 4),
     CALLDEF(laf_read_lines, 4),
     CALLDEF(laf_levels, 2),
     CALLDEF(colsum, 2),
     CALLDEF(colfreq, 2),
     CALLDEF(colrange, 2),
     CALLDEF(colnmissing, 2),
     CALLDEF(nlines, 1),
     CALLDEF(r_get_line, 2), 
     {NULL, NULL, 0}
  };

  void R_init_LaF(DllInfo *info) {
    R_registerRoutines(info, NULL, r_calldef, NULL, NULL);
    R_useDynamicSymbols(info, static_cast<Rboolean>(FALSE));
  }
}