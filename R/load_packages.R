#' Install missing packages and load them
#'
#' Installs packages that are not already installed, then loads every package in
#' the requested list.
#'
#' @param pkgs Character vector of package names.
#' @param install_missing Logical. If \code{TRUE}, install missing packages.
#' @param repos Repository argument passed to \code{install.packages()}.
#'
#' @return Invisibly returns the package names that were requested.
#'
#' @export
load_packages <- function(pkgs,
                          install_missing = TRUE,
                          repos = getOption("repos")) {
  if (!is.character(pkgs)) {
    stop("`pkgs` must be a character vector.", call. = FALSE)
  }

  pkgs <- unique(trimws(pkgs))
  pkgs <- pkgs[nzchar(pkgs)]

  if (!length(pkgs)) {
    return(invisible(pkgs))
  }

  if (!is.logical(install_missing) || length(install_missing) != 1L || is.na(install_missing)) {
    stop("`install_missing` must be TRUE or FALSE.", call. = FALSE)
  }

  new_pkgs <- setdiff(pkgs, rownames(utils::installed.packages()))

  if (length(new_pkgs)) {
    if (!isTRUE(install_missing)) {
      stop(
        "Missing package(s): ",
        paste(new_pkgs, collapse = ", "),
        call. = FALSE
      )
    }

    utils::install.packages(
      new_pkgs,
      repos = normalize_vlabr_repos(repos)
    )
  }

  invisible(
    lapply(
      pkgs,
      function(pkg) {
        library(pkg, character.only = TRUE)
      }
    )
  )
}

#' Load the default VLabR startup package set
#'
#' Loads the package set commonly used with VLabR workflows. Missing packages
#' are installed by default.
#'
#' @param pkgs Character vector of package names. Defaults to the VLabR startup
#'   package set.
#' @param install_missing Logical. If \code{TRUE}, install missing packages.
#' @param repos Repository argument passed to \code{install.packages()}.
#'
#' @return Invisibly returns the package names that were requested.
#'
#' @export
load_vlabr_packages <- function(
    pkgs = default_vlabr_packages(),
    install_missing = TRUE,
    repos = getOption("repos")) {
  load_packages(
    pkgs = pkgs,
    install_missing = install_missing,
    repos = repos
  )
}

#' Return the default VLabR startup package set
#'
#' @return A character vector of package names.
#'
#' @export
default_vlabr_packages <- function() {
  c(
    "tidyverse",
    "kableExtra",
    "knitr",
    "reshape2",
    "tidyr",
    "tidytext",
    "wordcloud",
    "RColorBrewer",
    "wordcloud2",
    "SnowballC",
    "tm",
    "VLabR",
    "lubridate"
  )
}

#' Enable automatic VLabR package loading at R startup
#'
#' Adds a managed block to an R startup profile, usually \code{~/.Rprofile}.
#' After this is enabled, future R sessions load the default VLabR package set
#' automatically.
#'
#' @param profile Path to the R profile file to update.
#' @param install_missing Logical. If \code{TRUE}, startup will install missing
#'   packages before loading them.
#'
#' @return Invisibly returns the profile path.
#'
#' @export
enable_vlabr_startup_packages <- function(
    profile = "~/.Rprofile",
    install_missing = TRUE) {
  if (!is.logical(install_missing) || length(install_missing) != 1L || is.na(install_missing)) {
    stop("`install_missing` must be TRUE or FALSE.", call. = FALSE)
  }

  profile <- path.expand(profile)
  profile_dir <- dirname(profile)

  if (!dir.exists(profile_dir)) {
    dir.create(profile_dir, recursive = TRUE, showWarnings = FALSE)
  }

  old_lines <- if (file.exists(profile)) {
    readLines(profile, warn = FALSE)
  } else {
    character()
  }

  old_lines <- remove_vlabr_startup_block(old_lines)

  block <- c(
    "# >>> VLabR startup packages >>>",
    "if (requireNamespace(\"VLabR\", quietly = TRUE)) {",
    paste0(
      "  VLabR::vlab_load_vlabr_packages(install_missing = ",
      if (isTRUE(install_missing)) "TRUE" else "FALSE",
      ")"
    ),
    "}",
    "# <<< VLabR startup packages <<<"
  )

  new_lines <- c(old_lines, "", block)
  writeLines(new_lines, profile, useBytes = TRUE)

  message("VLabR startup package loading enabled in: ", profile)
  invisible(profile)
}

#' Disable automatic VLabR package loading at R startup
#'
#' Removes the managed VLabR startup block from an R profile.
#'
#' @param profile Path to the R profile file to update.
#'
#' @return Invisibly returns the profile path.
#'
#' @export
disable_vlabr_startup_packages <- function(profile = "~/.Rprofile") {
  profile <- path.expand(profile)

  if (!file.exists(profile)) {
    return(invisible(profile))
  }

  old_lines <- readLines(profile, warn = FALSE)
  new_lines <- remove_vlabr_startup_block(old_lines)
  writeLines(new_lines, profile, useBytes = TRUE)

  message("VLabR startup package loading disabled in: ", profile)
  invisible(profile)
}

normalize_vlabr_repos <- function(repos) {
  if (
    !length(repos %||% character()) ||
      identical(unname(repos["CRAN"]), "@CRAN@")
  ) {
    return(c(CRAN = "https://cloud.r-project.org"))
  }

  repos
}

remove_vlabr_startup_block <- function(lines) {
  start <- grep("^# >>> VLabR startup packages >>>$", lines)
  end <- grep("^# <<< VLabR startup packages <<<$", lines)

  if (!length(start) || !length(end)) {
    return(lines)
  }

  keep <- rep(TRUE, length(lines))

  for (i in seq_along(start)) {
    block_end <- end[end >= start[i]][1]

    if (!is.na(block_end)) {
      keep[start[i]:block_end] <- FALSE
    }
  }

  lines[keep]
}
