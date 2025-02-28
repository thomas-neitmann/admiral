% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/assertions.R
\name{assert_param_does_not_exist}
\alias{assert_param_does_not_exist}
\title{Asserts That a Parameter Does Not Exist in the Dataset}
\usage{
assert_param_does_not_exist(dataset, param)
}
\arguments{
\item{dataset}{A \code{data.frame}}

\item{param}{Parameter code to check}
}
\value{
The function throws an error if the parameter exists in the input
dataset. Otherwise, the dataset is returned invisibly.
}
\description{
Checks if a parameter (\code{PARAMCD}) does not exist in a dataset.
}
\examples{
data(admiral_advs)
assert_param_does_not_exist(admiral_advs, param = "HR")
try(assert_param_does_not_exist(admiral_advs, param = "WEIGHT"))
}
\author{
Stefan Bundfuss
}
\keyword{assertion}
