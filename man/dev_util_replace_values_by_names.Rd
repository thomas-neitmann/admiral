% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dev_utils.R
\name{replace_values_by_names}
\alias{replace_values_by_names}
\title{Replace Quosure Value with Name}
\usage{
replace_values_by_names(quosures)
}
\arguments{
\item{quosures}{A list of quosures}
}
\value{
A list of quosures
}
\description{
Replace Quosure Value with Name
}
\examples{
admiral:::replace_values_by_names(vars(USUBJID, TEST = VSTESTCD))
}
\author{
Thomas Neitmann
}
\keyword{dev_utility}
