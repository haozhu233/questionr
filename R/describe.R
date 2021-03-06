#' Describe the variables of a data.frame
#'
#' This function describes the variables of a vector or a dataset that might
#' include labels imported with \pkg{haven} packages.
#' 
#' @note Labels imported with \pkg{foreign} or \pkg{memisc} package will be
#' displayed only in \pkg{labelled} package is installed.
#'
#' @param x object to describe
#' @param ... further arguments passed to or from other methods, see details
#' @return an object of class \code{description}.
#' @author Joseph Larmarange <joseph@@larmarange.net>
#' @export

`describe` <-
  function (x, ...) {
    UseMethod("describe")
  }

#' @rdname describe
#' @aliases describe.factor
#' @param n number of first values to display
#' @param show.length display length of the vector?
#' @examples
#' data(hdv2003)
#' describe(hdv2003$sexe)
#' @export

`describe.factor` <- 
  function(x, n = 5, show.length = TRUE, ...) {
    res <- ""
    if (show.length)
      res <- paste0("[", length(x), " obs.] ")
    res <- paste0(res, .get_var_label(x), "\n")
    
    if (is.ordered(x))
      res <- paste0(res, "ordinal factor: ")
    else
      res <- paste0(res, "nominal factor: ")
    
    quotes <- rep("\"", times = n)
    quotes[is.na(head(x, n = n))] <- ""
    obs <- paste0(quotes, head(x, n = n), quotes, collapse = " ")
    if (length(x) > n) obs <- paste(obs, "...")
    res <- paste0(res, obs, "\n")
    
    if (is.ordered(x))
      res <- paste0(res, nlevels(x), " levels: ", paste(levels(x), collapse = " < "), "\n")
    else
      res <- paste0(res, nlevels(x), " levels: ", paste(levels(x), collapse = " | "), "\n")
    
    nNA <- sum(is.na(x))
    res <- paste0(res, "NAs: ", nNA, " (", round(nNA / length(x), digits = 1), "%)")
    
    class(res) <- "description"
    return(res)
  }


#' @rdname describe
#' @aliases describe.numeric
#' @examples
#' describe(hdv2003$age)
#' @export

`describe.numeric` <- 
  function(x, n = 5, show.length = TRUE, ...) {
    res <- ""
    if (show.length)
      res <- paste0("[", length(x), " obs.] ")
    res <- paste0(res, .get_var_label(x), "\n")
    
    res <- paste0(res, class(x), ": ")
    
    obs <- paste0(head(x, n = n), collapse = " ")
    if (length(x) > n) obs <- paste(obs, "...")
    res <- paste0(res, obs, "\n")
    
    lab <- .get_val_labels(x)
    if (!is.null(lab)) {
      lab <- paste0("[", lab, "] ", names(lab))
      res <- paste0(res, length(lab), " labels: ", paste(lab, collapse = " "), "\n")
    }
    
    res <- paste0(res, "min: ", min(x, na.rm = T), " - max: ", max(x, na.rm = T), " - ")
    nNA <- sum(is.na(x))
    res <- paste0(res, "NAs: ", nNA, " (", round(nNA / length(x), digits = 1), "%)")
    res <- paste0(res, " - ", length(unique(x)), " unique values")
    
    class(res) <- "description"
    return(res)
  }

#' @rdname describe
#' @aliases describe.character
#' @export

`describe.character` <- 
  function(x, n = 5, show.length = TRUE, ...) {
    res <- ""
    if (show.length)
      res <- paste0("[", length(x), " obs.] ")
    res <- paste0(res, .get_var_label(x), "\n")
    
    res <- paste0(res, class(x), ": ")
    
    quotes <- rep("\"", times = n)
    quotes[is.na(head(x, n = n))] <- ""
    obs <- paste0(quotes, head(x, n = n), quotes, collapse = " ")
    if (length(x) > n) obs <- paste(obs, "...")
    res <- paste0(res, obs, "\n")
    
    lab <- .get_val_labels(x)
    if (!is.null(lab)) {
      lab <- paste0("[", lab, "] ", names(lab))
      res <- paste0(res, length(lab), " labels: ", paste(lab, collapse = " "), "\n")
    }
    
    nNA <- sum(is.na(x))
    res <- paste0(res, "NAs: ", nNA, " (", round(nNA / length(x), digits = 1), "%)")
    res <- paste0(res, " - ", length(unique(x)), " unique values")
    
    class(res) <- "description"
    return(res)
  }


#' @rdname describe
#' @aliases describe.default
#' @export

`describe.default` <- 
  function(x, n = 5, show.length = TRUE, ...) {
    if (!is.atomic(x)) stop("no method specified for this kind of object.")
    res <- ""
    if (show.length)
      res <- paste0("[", length(x), " obs.] ")
    res <- paste0(res, .get_var_label(x), "\n")
    
    res <- paste0(res, class(x), ": ")
    
    obs <- paste0(format(head(x, n = n), trim = TRUE), collapse = " ")
    if (length(x) > n) obs <- paste(obs, "...")
    res <- paste0(res, obs, "\n")
    
    res <- paste0(res, "min: ", min(x, na.rm = T), " - max: ", max(x, na.rm = T), " - ")
    nNA <- sum(is.na(x))
    res <- paste0(res, "NAs: ", nNA, " (", round(nNA / length(x), digits = 1), "%)")
    res <- paste0(res, " - ", length(unique(x)), " unique values")
    
    class(res) <- "description"
    return(res)
  }

#' @rdname describe
#' @aliases describe.labelled
#' @examples 
#' data(fecondite)
#' describe(femmes$milieu)
#' @export

`describe.labelled` <- 
  function(x, n = 5, show.length = TRUE, ...) {
    vl <- .get_val_labels(x)
    mv <- .get_missing_val(x)
    if (is.numeric(x)) {
      class(x) <- "labelled numeric"
      res <- describe.numeric(x, n = n, show.length = show.length, ...)
    }
    else if (is.character(x)) {
      class(x) <- "labelled character"
      res <- describe.character(x, n = n, show.length = show.length, ...)
    }
    else {
      res <- describe.default(x, n = n, show.length = show.length, ...)
    }
    if (!is.null(vl))
      res <- paste0(res, "\n", length(vl), " value labels: ", paste0("[", vl, "] ", names(vl), collapse = " "))
    if (!is.null(mv))
      res <- paste0(res, "\n", length(mv), " defined missing values: ", paste0(mv, collapse = ", "))
    
    class(res) <- "description"
    return(res)
  }

#' @rdname describe
#' @aliases describe.data.frame
#' @details When describing a data.frame, you can provide variable names as character strings. 
#' Using the "*" or "|" wildcards in a variable name will search for it using a regex match.
#' See examples.
#' @examples
#' describe(hdv2003)
#' describe(hdv2003, "cuisine", "heures.tv")
#' describe(hdv2003, "trav*")
#' describe(hdv2003, "trav|lecture")
#' describe(femmes)
#' @export

`describe.data.frame` <- 
  function(x, ..., n = 5) {
    # applying to_labelled if available
    if (requireNamespace("labelled", quietly = TRUE))
      x <- labelled::to_labelled(x)
    
    # select variables
    s <- c(...)
    
    if(is.null(s)) s <- names(x)
    
    m <- sapply(s, function(i) grepl(gsub("\\*", "", i), names(x)))
    m <- unlist(lapply(1:nrow(m), function(i) any(m[i, ])))
    s <- names(x)[m]
    
    y <- subset(x, select = s)
    
    res <- paste0("[", nrow(x), " obs. x ", ncol(x), " variables] ", paste(class(x), collapse = " "))
    
    for (v in names(y)) {
      attr(y[[v]], "label") <- .get_var_label(x[[v]]) # restoring labels lost when subsetting
      res <- paste0(res, "\n\n$", v, ": ", describe(y[[v]], n = n, show.length = FALSE))  
    }
    
    class(res) <- "description"
    return(res)
  }

#' @rdname describe
#' @export

`print.description` <- 
  function(x, ...) {
    cat(x)
    invisible(x)
  }