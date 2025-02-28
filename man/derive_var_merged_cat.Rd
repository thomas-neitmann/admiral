% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_merged.R
\name{derive_var_merged_cat}
\alias{derive_var_merged_cat}
\title{Merge a Categorization Variable}
\usage{
derive_var_merged_cat(
  dataset,
  dataset_add,
  by_vars,
  order = NULL,
  new_var,
  source_var,
  cat_fun,
  filter_add = NULL,
  mode = NULL,
  missing_value = NA_character_
)
}
\arguments{
\item{dataset}{Input dataset

The variables specified by the \code{by_vars} parameter are expected.}

\item{dataset_add}{Additional dataset

The variables specified by the \code{by_vars}, the \code{source_var}, and the \code{order}
parameter are expected.}

\item{by_vars}{Grouping variables

The input dataset and the selected observations from the additional dataset
are merged by the specified by variables. The by variables must be a unique
key of the selected observations.

\emph{Permitted Values}: list of variables created by \code{vars()}}

\item{order}{Sort order

If the parameter is set to a non-null value, for each by group the first or
last observation from the additional dataset is selected with respect to the
specified order.

\emph{Default}: \code{NULL}

\emph{Permitted Values}: list of variables or \verb{desc(<variable>)} function calls
created by \code{vars()}, e.g., \code{vars(ADT, desc(AVAL))} or \code{NULL}}

\item{new_var}{New variable

The specified variable is added to the additional dataset and set to the
categorized values, i.e., \verb{cat_fun(<source variable>)}.}

\item{source_var}{Source variable}

\item{cat_fun}{Categorization function

A function must be specified for this parameter which expects the values of
the source variable as input and returns the categorized values.}

\item{filter_add}{Filter for additional dataset (\code{dataset_add})

Only observations fulfilling the specified condition are taken into account
for merging. If the parameter is not specified, all observations are
considered.

\emph{Default}: \code{NULL}

\emph{Permitted Values}: a condition}

\item{mode}{Selection mode

Determines if the first or last observation is selected. If the \code{order}
parameter is specified, \code{mode} must be non-null.

If the \code{order} parameter is not specified, the \code{mode} parameter is ignored.

\emph{Default}: \code{NULL}

\emph{Permitted Values}: \code{"first"}, \code{"last"}, \code{NULL}}

\item{missing_value}{Values used for missing information

The new variable is set to the specified value for all by groups without
observations in the additional dataset.

\emph{Default}: \code{NA_character_}}
}
\value{
The output dataset contains all observations and variables of the
input dataset and additionally the variable specified for \code{new_var} derived
from the additional dataset (\code{dataset_add}).
}
\description{
Merge a categorization variable from a dataset to the input dataset. The
observations to merge can be selected by a condition and/or selecting the
first or last observation for each by group.
}
\details{
\enumerate{
\item The additional dataset is restricted to the observations matching the
\code{filter_add} condition.
\item The categorization variable is added to the additional dataset.
\item If \code{order} is specified, for each by group the first or last observation
(depending on \code{mode}) is selected.
\item The categorization variable is merged to the input dataset.
}
}
\examples{
library(admiral.test)
library(dplyr, warn.conflicts = FALSE)
data("admiral_dm")
data("admiral_vs")

wgt_cat <- function(wgt) {
  case_when(
    wgt < 50 ~ "low",
    wgt > 90 ~ "high",
    TRUE ~ "normal"
  )
}

derive_var_merged_cat(
  admiral_dm,
  dataset_add = admiral_vs,
  by_vars = vars(STUDYID, USUBJID),
  order = vars(VSDTC, VSSEQ),
  filter_add = VSTESTCD == "WEIGHT" & substr(VISIT, 1, 9) == "SCREENING",
  new_var = WGTBLCAT,
  source_var = VSSTRESN,
  cat_fun = wgt_cat,
  mode = "last"
) \%>\%
  select(STUDYID, USUBJID, AGE, AGEU, WGTBLCAT)

# defining a value for missing VS data
derive_var_merged_cat(
  admiral_dm,
  dataset_add = admiral_vs,
  by_vars = vars(STUDYID, USUBJID),
  order = vars(VSDTC, VSSEQ),
  filter_add = VSTESTCD == "WEIGHT" & substr(VISIT, 1, 9) == "SCREENING",
  new_var = WGTBLCAT,
  source_var = VSSTRESN,
  cat_fun = wgt_cat,
  mode = "last",
  missing_value = "MISSING"
) \%>\%
  select(STUDYID, USUBJID, AGE, AGEU, WGTBLCAT)
}
\author{
Stefan Bundfuss
}
\keyword{adam}
\keyword{derivation}
