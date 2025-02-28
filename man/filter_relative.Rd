% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_relative.R
\name{filter_relative}
\alias{filter_relative}
\title{Filter the Observations Before or After a Condition is Fulfilled}
\usage{
filter_relative(
  dataset,
  by_vars,
  order,
  condition,
  mode,
  selection,
  inclusive,
  keep_no_ref_groups = TRUE,
  check_type = "warning"
)
}
\arguments{
\item{dataset}{Input dataset

The variables specified by the \code{order} and the \code{by_vars} parameter are
expected.}

\item{by_vars}{Grouping variables

\emph{Permitted Values:} list of variables created by \code{vars()}}

\item{order}{Sort order

Within each by group the observations are ordered by the specified order.

\emph{Permitted Values:} list of variables or \verb{desc(<variable>)} function calls
created by \code{vars()}, e.g., \code{vars(ADT, desc(AVAL))}}

\item{condition}{Condition for Reference Observation

The specified condition determines the reference observation. The output
dataset contains all observations before or after (\code{selection} parameter)
the reference observation.}

\item{mode}{Selection mode (first or last)

If \code{"first"} is specified, for each by group the observations before or
after (\code{selection} parameter) the observation where the condition
(\code{condition} parameter) is fulfilled the \emph{first} time is included in the
output dataset. If \code{"last"} is specified, for each by group the
observations before or after (\code{selection} parameter) the observation where
the condition (\code{condition} parameter) is fulfilled the \emph{last} time is
included in the output dataset.

\emph{Permitted Values:} \code{"first"}, \code{"last"}}

\item{selection}{Select observations before or after the reference observation?

\emph{Permitted Values:} \code{"before"}, \code{"after"}}

\item{inclusive}{Include the reference observation?

\emph{Permitted Values:} \code{TRUE}, \code{FALSE}}

\item{keep_no_ref_groups}{Should by groups without reference observation be kept?

\emph{Default:} \code{TRUE}

\emph{Permitted Values:} \code{TRUE}, \code{FALSE}}

\item{check_type}{Check uniqueness?

If \code{"warning"} or \code{"error"} is specified, the specified message is issued
if the observations of the input dataset are not unique with respect to the
by variables and the order.

\emph{Default:} \code{"none"}

\emph{Permitted Values:} \code{"none"}, \code{"warning"}, \code{"error"}}
}
\value{
A dataset containing for each by group the observations before or
after the observation where the condition was fulfilled the first or last
time
}
\description{
Filters the observations before or after the observation where a specified
condition is fulfilled for each by group. For example, the function could be
called to select for each subject all observations before the first disease
progression.
}
\details{
For each by group ( \code{by_vars} parameter) the observations before or
after (\code{selection} parameter) the observations where the condition
(\code{condition} parameter) if fulfilled the first or last time (\code{order}
parameter and \code{mode} parameter) is included in the output dataset.
}
\examples{
library(dplyr, warn.conflict = FALSE)

response <- tibble::tribble(
  ~USUBJID, ~AVISITN, ~AVALC,
  "1",      1,        "PR",
  "1",      2,        "CR",
  "1",      3,        "CR",
  "1",      4,        "SD",
  "1",      5,        "NE",
  "2",      1,        "SD",
  "2",      2,        "PD",
  "2",      3,        "PD",
  "3",      1,        "SD",
  "4",      1,        "SD",
  "4",      2,        "PR",
  "4",      3,        "PD",
  "4",      4,        "SD",
  "4",      5,        "PR"
)

# Select observations up to first PD for each patient
response \%>\%
  filter_relative(
    by_vars = vars(USUBJID),
    order = vars(AVISITN),
    condition = AVALC == "PD",
    mode = "first",
    selection = "before",
    inclusive = TRUE
  )

# Select observations after last CR, PR, or SD for each patient
response \%>\%
  filter_relative(
    by_vars = vars(USUBJID),
    order = vars(AVISITN),
    condition = AVALC \%in\% c("CR", "PR", "SD"),
    mode = "last",
    selection = "after",
    inclusive = FALSE
  )

# Select observations from first response to first PD
response \%>\%
  filter_relative(
    by_vars = vars(USUBJID),
    order = vars(AVISITN),
    condition = AVALC \%in\% c("CR", "PR"),
    mode = "first",
    selection = "after",
    inclusive = TRUE,
    keep_no_ref_groups = FALSE
  ) \%>\%
  filter_relative(
    by_vars = vars(USUBJID),
    order = vars(AVISITN),
    condition = AVALC == "PD",
    mode = "first",
    selection = "before",
    inclusive = TRUE
  )
}
\author{
Stefan Bundfuss
}
\keyword{adam}
\keyword{user_utility}
