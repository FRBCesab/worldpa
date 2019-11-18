#' @title Get ISO3 code of all World countries
#'
#' @description Get the ISO3 code of all World countries from the Protected Planet website (based on the UNEP classification).
#'
#' @return A 3-columns data frame:
#' \itemize{
#'   \item region, the regions of the world
#'   \item country, the countries of the world
#'   \item iso3, the iso3 code of countries
#' }
#'
#' @details A Internet connexion is required.
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @importFrom rvest html_session html_nodes html_text html_table
#'
#' @export
#'
#' @examples
#' x <- get_isocodes()
#'
#' head(x)
#'
#' x[x[ , "region"] == "Africa", ]



get_isocodes <- function() {

  html <- rvest::html_session("https://www.protectedplanet.net/c/unep-regions")

  regions   <- rvest::html_nodes(html, ".region-link")
  regions   <- rvest::html_text(regions)

  countries <- rvest::html_table(html)
  names(countries) <- regions

  countries <- lapply(
    regions,
    function(x, countries) {
      countries[[x]] <- data.frame(region = x, countries[[x]])
    },
    countries
  )

  countries <- as.data.frame(do.call(rbind, countries))
  colnames(countries) <- c("region", "country", "iso3")

  return(countries)
}
