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

#ifndef CONVERSION_H
#define CONVERSION_H

#include <exception>
#include <string>

class ConversionError : public std::exception {};

int strtoint(const char* str, unsigned int nchar);
double strtodouble(const char* str, unsigned int nchar, char dec = '.');

bool all_chars_equal(const char* str, unsigned int n, char c = ' ');

std::string chartostring(const char* str, unsigned int length, bool trim = false);

    
#endif
