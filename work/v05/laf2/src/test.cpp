#include <Rcpp.h>
using namespace Rcpp;

#include "dynamicarray.h"

// [[Rcpp::export]]
int test_dynamicarray(int size) {
  DynamicArray<int> array{};
  for (int i = 0; i < size; ++i) array.push_back(i);
  array.truncate();
  return 0;
}

// [[Rcpp::export]]
NumericVector test_dynamicarray2r(int size) {
  DynamicArray<double> array{};
  for (int i = 0; i < size; ++i) array.push_back(i);
  // array.truncate();
  return NumericVector(array.data(), array.data() + size);
}

// [[Rcpp::export]]
SEXP test_purer(int size) {
  PROTECT_INDEX ipx;
  int len = 1024;
  SEXP res = PROTECT(Rf_allocVector(REALSXP, len));
  int pos = 0;
  double* p = REAL(res);
  for (int i = 0; i < size; ++i) {
    if (pos >= len) {
      int new_len = len * 2;
      SEXP newres = Rf_allocVector(REALSXP, new_len);
      double* newp = REAL(newres);
      std::memcpy(newp, p, sizeof(*p)*len);
      len = new_len;
      p = newp;
      UNPROTECT(1);
      res = PROTECT(newres);
    }
    p[pos++] = i;
  }
  // truncate
  int new_len = size;
  SEXP newres = Rf_allocVector(REALSXP, new_len);
  double* newp = REAL(newres);
  std::memcpy(newp, p, sizeof(*p)*new_len);
  UNPROTECT(1);
  res = PROTECT(newres);
  // done
  UNPROTECT(1);
  return res;
}

// [[Rcpp::export]]
SEXP test_purer2(int size) {
  PROTECT_INDEX ipx;
  int len = 1024;
  SEXP res;
  PROTECT_WITH_INDEX(res = Rf_allocVector(REALSXP, len), &ipx);
  int pos = 0;
  double* p = REAL(res);
  for (int i = 0; i < size; ++i) {
    if (pos >= len) {
      int new_len = len * 2;
      SEXP newres = Rf_allocVector(REALSXP, new_len);
      double* newp = REAL(newres);
      std::memcpy(newp, p, sizeof(*p)*len);
      len = new_len;
      p = newp;
      REPROTECT(res = newres, ipx);
    }
    p[pos++] = i;
  }
  // truncate
  int new_len = size;
  SEXP newres = Rf_allocVector(REALSXP, new_len);
  double* newp = REAL(newres);
  std::memcpy(newp, p, sizeof(*p)*new_len);
  REPROTECT(res = newres, ipx);
  // done
  UNPROTECT(1);
  return res;
}

