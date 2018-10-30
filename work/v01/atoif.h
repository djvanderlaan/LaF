
inline int atoif(const char* str, std::size_t len) {
  int value = 0;
  // skip whitespace
  while (len > 0 && *str == ' ') {
    ++str;
    --len;
  }
  // if (!len) error
  while (len > 0 && *str != ' ') {
    int v = *str - '0';
    if (v >= 0 && v < 10) value = value * 10 + v;
    else break;
    //else error
    ++str;
    --len;
  }
  // check if at least one numeric
  return value;
}

const int NA_INT = 0;

int atoif2(const char* str, std::size_t len, int na = 0) {
  // skip whitespace
  while (len > 0 && *str == ' ') {
    ++str;
    --len;
  }
  // check number
  bool num = false;
  while (len > 0 && *str >= '0' && *str <= '9') {
    ++str;
    --len;
    num = true;
  }
  // check remainder
  bool err = false;
  while (len > 0 && *str == ' ') {
    if (!(*str >= '0' && *str <= '9') && (*str != ' ')) err = true;
    ++str;
    --len;
  }
}

