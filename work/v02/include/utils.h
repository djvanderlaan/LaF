#ifndef utils_h
#define utils_h

void print_char(std::ostream& out, char c) {
  if (c == '\n') {
    out << "<newline>";
  } else if (c == '\r') {
    out << "<carriage return>";
  } else if (c == 0) {
    out << "<0>";
  } else {
    out << "'" << c << "'";
  }
}

#endif
