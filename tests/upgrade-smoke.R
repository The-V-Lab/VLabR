library(VLabR)

# Vectorized duplicate grouping must treat NA keys as equal.
d <- data.frame(
  a = c("x", "x", "y", NA, NA, "z"),
  b = c(1, 1, 1, 2, 2, 3),
  val = 1:6
)
r1 <- vlab_get_duplicates(d, a, b, .keep_all = TRUE, .sort = FALSE)
r2 <- vlab_get_duplicates(d, a, b, .keep_all = FALSE, .sort = TRUE)
stopifnot(identical(r1$.n, c(2L, 2L, NA, 2L, 2L, NA)))
stopifnot(nrow(r2) == 2L, all(r2$.n == 2L))

df <- data.frame("Col (1)" = 1:3, "Name's-Age" = c(20, 25, 30), check.names = FALSE)
fixed <- vlab_fix_colname(df)
stopifnot(identical(names(fixed), c("Col_1", "NamesAge")))

q <- vlab_quote_rm(data.frame(a = "O'Neil", b = factor("\"Hello\""), n = 1))
stopifnot(identical(q$a, "ONeil"), identical(as.character(q$b), "Hello"))

stopifnot(vlab_count_unique_categories(data.frame(g = c("A", "B", "A", NA)), "g") == 2L)
stopifnot(isFALSE(vlab_check_unique(data.frame(id = c("a", "b", "a")), id)$is_unique))
stopifnot(isTRUE(vlab_check_unique(data.frame(id = 1:3), id)$is_unique))
stopifnot(isTRUE(vlab_check_unique(data.frame(id = c("a", "b", NA)), id, na.rm = TRUE)$is_unique))

ids <- vlab_SID_creator("Ann", "O'Neil", "1990-07-03", "F")
stopifnot(identical(ids, "ANON19900703F"))

stopifnot(identical(vlab_mask(c("abc", NA), n = 2), c("**c", NA_character_)))
stopifnot(identical(vlab_second2format(1000), "00:16:40"))
stopifnot(identical(vlab_similarscore("E123456", "e1223456"), 0.875))
stopifnot(identical(vlab_withintime("2026-10-14 09:00", "2026-10-14 12:00", 3), 1L))
stopifnot(identical(vlab_today("2024-01-05")[["YMD_compact"]], "20240105"))

message("upgrade-smoke: ok")
