% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_query_data.R
\name{sdg_select}
\alias{sdg_select}
\title{Create an \code{sdg_select} object}
\usage{
sdg_select(name = NULL, id = NULL)
}
\arguments{
\item{name}{Name of the query used to select the definition of the query
from the company database.}

\item{id}{Identifier of the query used to select the definition of the query
from the company database.}
}
\value{
An object of class \code{sdg_select}.
}
\description{
Create an \code{sdg_select} object
}
\details{
Exactly one \code{name} or \code{id} must be specified.
}
\seealso{
\code{\link[=create_query_data]{create_query_data()}}, \code{\link[=query]{query()}}
}
\author{
Stefan Bundfuss
}
\keyword{source_specifications}
