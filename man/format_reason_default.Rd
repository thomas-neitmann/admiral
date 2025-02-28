% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_vars_disposition_reason.R
\name{format_reason_default}
\alias{format_reason_default}
\title{Default Format for the Disposition Reason}
\usage{
format_reason_default(reason, reason_spe = NULL)
}
\arguments{
\item{reason}{the disposition variable used for the mapping (e.g. \code{DSDECOD}).}

\item{reason_spe}{the disposition variable used for the mapping of the details
if required (e.g. \code{DSTERM}).}
}
\value{
A \code{character} vector
}
\description{
Define a function to map the disposition reason, to be used as a parameter in
\code{derive_vars_disposition_reason()}.
}
\details{
\code{format_reason_default(DSDECOD)} returns \code{DSDECOD} when \code{DSDECOD} is not \code{'COMPLETED'} nor \code{NA}.
\cr\code{format_reason_default(DSDECOD, DSTERM)} returns \code{DSTERM} when \code{DSDECOD} is
equal to \code{'OTHER'}.
\cr Usually this function can not be used with \verb{\%>\%}.
}
\examples{
library(dplyr, warn.conflicts = FALSE)
library(admiral.test)
data("admiral_dm")
data("admiral_ds")

# Derive DCSREAS using format_reason_default
admiral_dm \%>\%
  derive_vars_disposition_reason(
    dataset_ds = admiral_ds,
    new_var = DCSREAS,
    reason_var = DSDECOD,
    format_new_vars = format_reason_default,
    filter_ds = DSCAT == "DISPOSITION EVENT"
  ) \%>\%
  select(STUDYID, USUBJID, DCSREAS)
}
\seealso{
\code{\link[=derive_vars_disposition_reason]{derive_vars_disposition_reason()}}
}
\author{
Samia Kabi
}
\keyword{adsl}
\keyword{computation}
\keyword{user_utility}
