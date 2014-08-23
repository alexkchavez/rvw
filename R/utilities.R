#' Adapted from ?grep
#' @keywords internal
parseRegexResults <- function(x, regex.result) {
  parsed <- lapply(seq_along(x), function(i) {
    if (regex.result[i] == -1) stop(paste0("Could not parse ", x[i]))
    st <- attr(regex.result, "capture.start")[i, ]
    l <- substring(x[i], st, st + attr(regex.result, "capture.length")[i, ] - 1)
    names(l) <- attr(regex.result, "capture.names")
    l
  })
  if (length(parsed) == 1) parsed[[1]] else parsed
}
