% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_var_trtedtm.R
\name{derive_var_trtedtm}
\alias{derive_var_trtedtm}
\title{Derive Datetime of Last Exposure to Treatment}
\usage{
derive_var_trtedtm(
  dataset,
  dataset_ex,
  filter_ex = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
    nchar(EXENDTC) >= 10,
  subject_keys = vars(STUDYID, USUBJID)
)
}
\arguments{
\item{dataset}{Input dataset

The variables specified by the \code{by_vars} parameter are expected.}

\item{dataset_ex}{\code{ex} dataset

The variables \code{EXENDTC}, \code{EXSEQ}, and those specified by the \code{filter_ex}
parameter are expected.}

\item{filter_ex}{Filter condition for the ex dataset

Only observations of the ex dataset which fulfill the specified condition
are considered for the treatment start date.

Default: \code{EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, 'PLACEBO')) & nchar(EXENDTC) >= 10}

Permitted Values: logical expression}

\item{subject_keys}{Variables to uniquely identify a subject

A list of quosures where the expressions are symbols as returned by
\code{vars()} is expected.}
}
\value{
The input dataset with \code{TRTEDTM} variable added
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}

This function is \emph{deprecated}, please use \code{derive_vars_merged_dtm()} instead.

Derives datetime of last exposure to treatment (\code{TRTEDTM})
}
\details{
For each group (with respect to the variables specified for the
\code{by_vars} parameter) the first observation (with respect to the order
specified for the \code{order} parameter) is included in the output dataset.
}
\author{
Stefan Bundfuss
}
\keyword{adsl}
\keyword{derivation}
\keyword{timing}
