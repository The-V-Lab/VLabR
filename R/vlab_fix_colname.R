#' Clean column names by removing special characters and replacing spaces
#'
#' This function standardizes column names by:
#' - Replacing spaces with underscores
#' - Removing parentheses `()`
#' - Removing single quotes `'`
#' - Removing hyphens `-`
#'
#' @param the_data A data frame whose column names need fixing
#'
#' @return A data frame with cleaned column names
#' @examples
#' df <- data.frame("Col (1)" = 1:3, "Name's-Age" = c(20, 25, 30))
#' vlab_fix_colname(df)
#'
#' @export
vlab_fix_colname <- function(the_data) {
  colnames(the_data) <- colnames(the_data) |>
    gsub(" ", "_", x = _, fixed = TRUE) |>
    gsub("[()]", "", x = _) |>
    gsub("'", "", x = _, fixed = TRUE) |>
    gsub("-", "", x = _, fixed = TRUE)
  the_data
}
