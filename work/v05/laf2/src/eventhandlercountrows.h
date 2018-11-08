#ifndef eventhandlercountrows_h
#define eventhandlercountrows_h

class EventHandlerCountRows {
  public:
    EventHandlerCountRows() {
    }

    void start_reading() {
      nrow_ = 0;
      ncol_ = 0;
      col_ = 0;
    }

    void finished_reading() {
    }

    void new_record(char* p, std::size_t len) {
      col_++;
      if (col_ > ncol_) ncol_ = col_;
    }

    void end_of_line() {
      col_ = 0;
      nrow_++;
    }

    std::size_t ncol() const { return ncol_;}
    std::size_t nrow() const { return nrow_;}

  private:
    std::size_t nrow_;
    std::size_t ncol_;
    std::size_t col_;
};

#endif
