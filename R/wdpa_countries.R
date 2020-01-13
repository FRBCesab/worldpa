#' @title List of countries distributed in the UNEP regions
#' @description This dataset contains informations about countries listed on the Protected Planet project (\url{https://www.protectedplanet.net})
#'
#' @format A data frame with 248 rows (countries) and 5 columns:
#' \describe{
#'   \item{region_name}{The name of the region;}
#'   \item{region_iso2}{The ISO-2 code of the region;}
#'   \item{country_name}{The name of the country;}
#'   \item{country_iso3}{The ISO-3 code of the country;}
#'   \item{pas_count}{Number of protected areas per country.}
#' }
#'
#' This dataset has been built using the Protected Planet API the 2020/01/13. For a more up-to-date version, please use the function \code{wdpa::get_countries(update = TRUE)}.
#'
#' @source \url{https://www.protectedplanet.net/c/unep-regions}


"wdpa_countries"
