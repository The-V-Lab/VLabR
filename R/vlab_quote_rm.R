#' Remove quotes from character/factor columns
#'
#' Strips common quote characters from character and factor columns,
#' leaving other column types unchanged.
#'
#' @param data A data.frame or tibble.
#' @param chars Quote characters to remove, applied literally (not regex).
#'   Default removes straight, curly, and backtick quotes.
#' @return The same data type with quotes removed from relevant columns.
#' @examples
#' df <- data.frame(a = "O'Neil", b = factor("\u201dHello\u201d"), n = 1)
#' vlab_quote_rm(df)
#' @export
vlab_quote_rm <- function(data,
                        chars = c("'", "\u2019", "\"", "\u201c", "\u201d", "`")) {
  if (!is.data.frame(data)) stop("`data` must be a data.frame")

  strip_chars <- function(x) {
    Reduce(\(value, ch) gsub(ch, "", value, fixed = TRUE), chars, init = x)
  }

  data[] <- lapply(data, \(column) {
    if (is.character(column)) {
      strip_chars(column)
    } else if (is.factor(column)) {
      stripped <- strip_chars(as.character(column))
      factor(stripped, levels = unique(stripped))
    } else {
      column
    }
  })
  data
}
