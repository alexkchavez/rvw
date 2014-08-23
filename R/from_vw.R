#' Convert Vowpwal Wabbit Dataset to List or Data Frame
#' 
#' Convert a vector of strings in Vowpal Wabbit format to a list of sparse data frames or
#' to a dense data frame.
#' 
#' Vowpal Wabbit strings are in the format:
#' 
#' [Label] [Importance [Tag]]|Namespace Features |Namespace Features ... |Namespace Features
#' 
#' where 
#' 
#' \itemize{
#'   \item Label is an real number representing the dependent variable. Because examples can be unlabeled, Label is optional.
#'   \item Importance is the non-negative importance weight, and defaults to 1.0 if unspecified.
#'   \item Tag is an optional tag for the example, and defaults to NA if unspecified.
#'   \item Namespace=String[:Value] is a namespace string optionally followed by a float representing the global weight for features in the namespace. If the weight is omitted, 1.0 is substituted.
#'   \item Features=(String[:Value] )* is a sequence of feature names optionally followed by a float representing the feature weight. If the weight is omitted, 1.0 is substituted.
#' }
#' 
#' Conversion to R objects occurs by concatenating the namespace string with each feature
#' name in that namespace, and multiplying the namespace global weight with the feature
#' weight.
#' 
#' Additional details on the Vowpal Wabbit format can be found here:
#' \url{https://github.com/JohnLangford/vowpal_wabbit/wiki/Input-format}.
#'
#' @param x vector of Vowpal Wabbit strings.
#' @param dense whether to return the data in dense format as a data frame, or in a sparse
#'   format as a list. Defaults to false.
#' @param keepvw whether to include the original Vowpal Wabbit string in the output. 
#'   Defaults to false.
#' @return Data frame of examples including columns label, importance, tag, feature 
#'   values, and optionally the raw input string.
#' @examples
#' vw <- c(
#'   "1 2 'tag|a:2 b:3",
#'   "0 |f:.23 sqft:.25 age:.05 2006"
#' )
#'   
#' fromVw(x = vw, dense = FALSE)
#' # [[1]]
#' #   label importance  tag a_b
#' # 1     1          2 'tag   6
#' #
#' # [[2]]
#' #   label importance  tag f_sqft  f_age f_2006
#' # 1     0          1 <NA> 0.0575 0.0115   0.23
#'
#' fromVw(x = vw, dense = TRUE)
#' #   label importance  tag a_b f_sqft  f_age f_2006
#' # 1     1          2 'tag   6     NA     NA     NA
#' # 2     0          1 <NA>  NA 0.0575 0.0115   0.23
#'
#' @export
fromVw <- function(x, dense = FALSE, keepvw = FALSE) {
  regex <- '^(?<label>[^ ]+) (?:(?<importance>[^ ]+) (?:(?<tag>[^ ]+))?)?\\|(?<features>[^ ].*)'

  sparse.features <- lapply(x, function(vw) {
    regex.result <- regexpr(regex, vw, perl = TRUE)
    parsed <- as.list(parseRegexResults(vw, regex.result))
    l <- {
      l <- if (keepvw) parsed else parsed[c("label", "importance", "tag")]
      l$importance <- if (l$importance == "") 1.0 else as.numeric(l$importance)
      l$tag <- if (l$tag == "") NA_character_ else l$tag
      c(l, vwNamespacesToList(parsed$features))
    }
    data.frame(l, stringsAsFactors = FALSE)
  })
  
  if (!dense) {
    sparse.features
  } else {
    as.data.frame(data.table::rbindlist(sparse.features, fill = TRUE))
  }
}

#' Convert the Vowpal Wabbit 'Namespace Features |Namespace Features ... |Namespace
#' Features' to a list
#' 
#' @param x Namespace Features |Namespace Features ... |Namespace Features
#' @return list of lists with names equal to the namespace prepended to feature names and 
#'   values equal to the product of the namespace weight and feature weights.
#' @examples
#'   # Returns list(namespace1_feature1 = 4.0, namespace1_feature2 = 6.0,
#'   # namespace2_feature1 = 1.0, namespace2_feature3 = 1.0)
#'   vwNamespacesToList('namespace1:2.0 feature1:2.0 feature2:3.0 |namespace2 feature1 feature3')
#' @keywords internal
#' @export
vwNamespacesToList <- function(x) {
  feature.sections <- unlist(strsplit(x, split = ' |', fixed = TRUE))
  lapply(feature.sections, vwNamespaceToList)
}

#' Convert Vowpal Wabbit 'Namespace Features ' section to a list
#' 
#' Converts Vowpal Wabbit 'Namespace Features ' section by concatenating the namespace
#' string with each feature name and multiplying the namespace global weight with the
#' feature weight. Namespace=String[:Value] is a namespace string optionally followed by a
#' float representing the global weight for features in the namespace, and 
#' Features=(String[:Value] )* is a sequence of feature names optionally followed by a 
#' float representing the feature weight. If a weight is omitted, 1.0 is substituted.
#' 
#' @param x Vowpal Wabbit 'Namespace Features ' section where Namespace=String[:Value] and
#'   Features=(String[:Value] )*. If a weight is omitted, 1.0 is substituted.
#' @return list with names equal to the namespace prepended to feature names and values 
#'   equal to the product of the namespace weight and feature weights.
#' @examples
#'   # Returns list(namespace1_feature1 = 4.0, namespace1_feature2 = 6.0)
#'   vwNamespaceToList('namespace1:2.0 feature1:2.0 feature2:3.0 ')
#'   # Returns list(namespace2_feature1 = 1.0, namespace2_feature3 = 1.0)
#'   vwNamespaceToList('namespace2 feature1 feature3 ')
#' @keywords internal
#' @export
vwNamespaceToList <- function(x) {
  
  regex <- '(?<feature>[^:]+)(?::(?<weight>.*))?'
  
  .normalize <- function(fw) {
    if (length(fw) <= 1) stop(paste0("Could not parse: ", fw))
    regex.result <- regexpr(regex, fw, perl = TRUE)
    m <- {
      m <- do.call(rbind, parseRegexResults(fw, regex.result))
      m[m[, "weight"] == "", "weight"] <- "1.0"
      m
    }
    namespace.feature <- paste0(m[1, "feature"], "_", m[-1, "feature"])
    l <- {
      adjusted.weight <- as.list(as.numeric(m[1, "weight"]) * as.numeric(m[-1, "weight"]))
      names(adjusted.weight) <- namespace.feature
      adjusted.weight
    }
    l
  }
  
  .normalize(unlist(strsplit(x, split = " ", fixed = TRUE)))
}
