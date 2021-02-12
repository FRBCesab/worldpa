#' World Countries Distributed in the UNEP-WCMC Regions
#'
#' This dataset contains informations about countries listed on the Protected
#'   Planet project (\url{https://www.protectedplanet.net}). This dataset has
#'   been built using the Protected Planet API the 2021/02/12. For a more
#'   up-to-date version, please use the function `get_countries`.
#'
#' @format A data frame with 248 rows (countries) and the following 5 columns:
#' \describe{
#'   \item{region_name}{the name of the region}
#'   \item{region_iso2}{the ISO-2 code of the region}
#'   \item{country_name}{the name of the country}
#'   \item{country_iso3}{the ISO-3 code of the country}
#'   \item{pas_count}{the number of protected areas per country}
#' }
#'
#' @source \url{https://www.protectedplanet.net/c/unep-regions}

"wdpa_countries"
