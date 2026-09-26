library(VLabR)

values <- c("1023056", "98765", NA_character_, "", "  ")
cat_value <- paste0(intToUtf8(0x732B), "AB")
accent_value <- paste0(intToUtf8(c(0x65, 0x301)), "x")
family_value <- paste0(
  intToUtf8(c(0x1F468, 0x200D, 0x1F469, 0x200D, 0x1F467)),
  "X"
)

stopifnot(
  identical(
    vlab_mask(values),
    c("*******", "*****", NA_character_, "", "**")
  ),
  identical(
    vlab_mask(values, side = "front", n = 3),
    c("***3056", "***65", NA_character_, "", "**")
  ),
  identical(
    vlab_mask(values, side = "back", n = 3),
    c("1023***", "98***", NA_character_, "", "**")
  ),
  identical(vlab_mask("abc", n = 0), "abc"),
  identical(vlab_mask("abc", side = "back", n = 20), "***"),
  identical(vlab_mask(character()), character()),
  identical(vlab_mask(factor(c("AB", "CD")), n = 1), c("*B", "*D")),
  identical(vlab_mask(c(1023056, 42), n = 3), c("***3056", "**")),
  identical(vlab_mask(c(TRUE, FALSE)), c("****", "*****")),
  identical(vlab_mask(as.Date("2026-08-27")), "**********"),
  identical(vlab_mask(c(cat_value, accent_value), n = 1), c("*AB", "*x")),
  identical(
    vlab_mask(cat_value, side = "back", n = 2),
    paste0(intToUtf8(0x732B), "**")
  ),
  identical(vlab_mask(family_value, n = 1), "*X")
)

named_input <- structure(
  c("alpha", "beta", NA_character_, ""),
  names = c("duplicate", "duplicate", "", NA_character_)
)
named_output <- vlab_mask(named_input, side = "back", n = 2)

stopifnot(
  is.character(named_output),
  identical(length(named_output), length(named_input)),
  identical(names(named_output), names(named_input)),
  identical(unname(named_output), c("alp**", "be**", NA_character_, "")),
  identical(names(vlab_mask(named_input)), names(named_input)),
  identical(formals(vlab_mask)$side, "front"),
  is.null(formals(vlab_mask)$n)
)

invalid_calls <- list(
  function() vlab_mask(NULL),
  function() vlab_mask(list("abc")),
  function() vlab_mask(data.frame(value = "abc")),
  function() vlab_mask(matrix("abc")),
  function() vlab_mask("abc", side = "middle"),
  function() vlab_mask("abc", side = NA_character_),
  function() vlab_mask("abc", side = c("front", "back")),
  function() vlab_mask("abc", n = -1),
  function() vlab_mask("abc", n = 1.5),
  function() vlab_mask("abc", n = Inf),
  function() vlab_mask("abc", n = NA_real_),
  function() vlab_mask("abc", n = TRUE),
  function() vlab_mask("abc", n = c(1, 2)),
  function() vlab_mask("abc", n = "1")
)

stopifnot(all(vapply(
  invalid_calls,
  function(call) inherits(tryCatch(call(), error = identity), "error"),
  logical(1)
)))

sensitive_error <- tryCatch(
  vlab_mask("do-not-repeat-this-value", n = -1),
  error = identity
)
stopifnot(
  inherits(sensitive_error, "error"),
  !grepl("do-not-repeat-this-value", conditionMessage(sensitive_error), fixed = TRUE)
)
