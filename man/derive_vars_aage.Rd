% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_vars_aage.R
\name{derive_vars_aage}
\alias{derive_vars_aage}
\title{Derive Analysis Age}
\usage{
derive_vars_aage(
  dataset,
  start_date = BRTHDT,
  end_date = RANDDT,
  unit = "years"
)
}
\arguments{
\item{dataset}{Input dataset

The columns specified by the \code{start_date} and the \code{end_date} parameter are
expected.}

\item{start_date}{The start date

A date or date-time object is expected.

Refer to \code{derive_vars_dt()} to impute and derive a date from a date character
vector to a date object.

Default: \code{BRTHDT}}

\item{end_date}{The end date

A date or date-time object is expected.

Refer to \code{derive_vars_dt()} to impute and derive a date from a date character
vector to a date object.

Default: \code{RANDDT}}

\item{unit}{Unit

The age is derived in the specified unit

Default: 'years'

Permitted Values: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'}
}
\value{
The input dataset with \code{AAGE} and \code{AAGEU} added
}
\description{
Derives analysis age (\code{AAGE}) and analysis age unit (\code{AAGEU})
}
\details{
The age is derived as the integer part of the duration from start to
end date in the specified unit.
}
\examples{
data <- tibble::tribble(
  ~BRTHDT, ~RANDDT,
  lubridate::ymd("1984-09-06"), lubridate::ymd("2020-02-24")
)

derive_vars_aage(data)
}
\seealso{
\code{\link[=derive_vars_duration]{derive_vars_duration()}}
}
\author{
Stefan Bundfuss
}
