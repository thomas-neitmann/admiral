% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_var_dthcaus.R
\name{dthcaus_source}
\alias{dthcaus_source}
\title{Create a \code{dthcaus_source} Object}
\usage{
dthcaus_source(
  dataset_name,
  filter,
  date,
  mode = "first",
  dthcaus,
  traceability_vars = NULL
)
}
\arguments{
\item{dataset_name}{The name of the dataset, i.e. a string, used to search for
the death cause.}

\item{filter}{An expression used for filtering \code{dataset}.}

\item{date}{A character vector to be used for sorting \code{dataset}.}

\item{mode}{One of \code{"first"} or \code{"last"}.
Either the \code{"first"} or \code{"last"} observation is preserved from the \code{dataset}
which is ordered by \code{date}.}

\item{dthcaus}{A variable name or a string literal --- if a variable name, e.g., \code{AEDECOD},
it is the variable in the source dataset to be used to assign values to
\code{DTHCAUS}; if a string literal, e.g. \code{"Adverse Event"}, it is the fixed value
to be assigned to \code{DTHCAUS}.}

\item{traceability_vars}{A named list returned by \code{\link[=vars]{vars()}} listing the traceability variables,
e.g. \code{vars(DTHDOM = "DS", DTHSEQ = DSSEQ)}.
The left-hand side (names of the list elements) gives the names of the traceability variables
in the returned dataset.
The right-hand side (values of the list elements) gives the values of the traceability variables
in the returned dataset.
These can be either strings or symbols referring to existing variables.}
}
\value{
An object of class "dthcaus_source".
}
\description{
Create a \code{dthcaus_source} Object
}
\seealso{
\code{\link[=derive_var_dthcaus]{derive_var_dthcaus()}}
}
\author{
Shimeng Huang
}
\keyword{source_specifications}
