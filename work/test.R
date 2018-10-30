library(LaF)

d <- iris[sample(nrow(iris), 5E6, replace = TRUE), ]
write.csv(d, "test.csv")

m <- detect_dm_csv("test.csv")
l <- laf_open(m)
t <- system.time({
  d <- l[, ]
})

print(t)


d <- data.frame(
  a = sample(-50:50, 5E6, replace = TRUE),
  b = sample(-50:50, 5E6, replace = TRUE),
  c = sample(-50:50, 5E6, replace = TRUE),
  d = sample(-50:50, 5E6, replace = TRUE),
  e = sample(-50:50, 5E6, replace = TRUE),
  f = sample(-50:50, 5E6, replace = TRUE),
  g = sample(-50:50, 5E6, replace = TRUE)
  )

write.csv(d, "test2.csv", row.names = FALSE, col.names = FALSE)

print(sum(d))

m <- detect_dm_csv("test2.csv", header = FALSE)
l <- laf_open(m)
t <- system.time({
  d <- l[, ]
})


print(t)
