#' Get duplicate rows by one or more keys
#'
#' Find duplicates based on selected columns. If no columns are selected,
#' duplicates are computed across all columns.
#'
#' @param data A data.frame or tibble.
#' @param ... Columns used as the duplicate keys, as unquoted names or strings.
#' @param .min_n Minimum frequency to keep (default 2).
#' @param .keep_all If TRUE, return all original rows with a count column.
#'   If FALSE, return one row per key with the count only.
#' @param na.rm If TRUE, drop rows where any key column is NA before counting.
#' @param .count_col Name of the count column to add (default ".n").
#' @param .sort If TRUE, sort descending by count (then keys).
#'
#' @return A data frame with duplicates and a count column.
#' @examples
#' # One key
#' vlab_get_duplicates(mtcars, cyl)
#' # Multiple keys
#' vlab_get_duplicates(mtcars, cyl, gear, .keep_all = FALSE)
#' # All columns (exact duplicate rows)
#' vlab_get_duplicates(mtcars)
#' @export
vlab_get_duplicates <- function(data, ...,
                              .min_n = 2,
                              .keep_all = TRUE,
                              na.rm = FALSE,
                              .count_col = ".n",
                              .sort = TRUE) {
  stopifnot(is.data.frame(data))

  dots <- as.list(substitute(list(...)))[-1L]
  flatten_keys <- \(expr) {
    if (is.call(expr) && identical(expr[[1L]], as.name("c"))) {
      unlist(lapply(as.list(expr)[-1L], flatten_keys), recursive = FALSE)
    } else {
      list(expr)
    }
  }

  key_exprs <- unlist(lapply(dots, flatten_keys), recursive = FALSE)
  keys <- if (length(key_exprs) == 0L) {
    names(data)
  } else {
    out <- character()
    for (expr in key_exprs) {
      if (is.name(expr)) {
        out <- c(out, as.character(expr))
      } else if (is.character(expr)) {
        out <- c(out, expr)
      } else {
        value <- eval(expr, parent.frame())
        if (is.character(value)) {
          out <- c(out, value)
        } else if (is.numeric(value)) {
          out <- c(out, names(data)[value])
        } else {
          stop("Columns in `...` must be unquoted names, strings, or numeric positions.", call. = FALSE)
        }
      }
    }
    unique(out)
  }

  if (!all(keys %in% names(data))) {
    missing_keys <- setdiff(keys, names(data))
    stop("Column(s) not found in `data`: ", paste(missing_keys, collapse = ", "), call. = FALSE)
  }

  dat <- data
  if (na.rm && length(keys) > 0) {
    dat <- dat[stats::complete.cases(dat[, keys, drop = FALSE]), , drop = FALSE]
  }

  count_groups <- function(dat, keys) {
    n <- nrow(dat)
    if (length(keys) == 0L) {
      counts <- data.frame(stringsAsFactors = FALSE)
      counts[[.count_col]] <- n
      return(list(counts = counts, row_counts = rep(n, n)))
    }

    key_frame <- dat[, keys, drop = FALSE]
    if (n == 0L) {
      counts <- key_frame
      counts[[.count_col]] <- integer()
      return(list(counts = counts, row_counts = integer()))
    }

    group_id <- Reduce(
      \(left, col) {
        pair <- interaction(
          left,
          match(col, unique(col)),
          drop = TRUE,
          lex.order = TRUE
        )
        match(pair, unique(pair))
      },
      key_frame,
      init = rep(1L, n)
    )
    group_counts <- tabulate(group_id, nbins = max(group_id))
    first <- !duplicated(key_frame)
    counts <- key_frame[first, , drop = FALSE]
    counts[[.count_col]] <- group_counts[group_id[first]]
    list(counts = counts, row_counts = group_counts[group_id])
  }

  grouped <- count_groups(dat, keys)
  counts <- grouped$counts[grouped$counts[[.count_col]] >= .min_n, , drop = FALSE]

  if (.keep_all) {
    out <- dat
    out[[.count_col]] <- grouped$row_counts
    out[[.count_col]][out[[.count_col]] < .min_n] <- NA_integer_
  } else {
    out <- counts
  }

  if (.sort) {
    count_values <- out[[.count_col]]
    order_args <- c(
      list(is.na(count_values), -count_values),
      out[, keys, drop = FALSE],
      list(na.last = TRUE)
    )
    out <- out[do.call(order, order_args), , drop = FALSE]
  }

  row.names(out) <- NULL
  out
}
