
len <- 1E7


system.time(x <- test_dynamicarray(len))
system.time(x <- test_dynamicarray2r(len))
system.time(x <- test_purer(len))


library(microbenchmark)

microbenchmark(
  x <- test_dynamicarray(len),
  x <- test_dynamicarray2r(len),
  x <- test_purer(len)
)
