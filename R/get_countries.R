#' @title Get World countries names
#'
#' @description Get World countries names from the Protected Planet website (based on the UNEP classification).
#'
#' @return A vector of World countries names.
#'
#' @details A Internet connexion is required.
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @importFrom rvest html_session html_table
#'
#' @export
#'
#' @examples
#' x <- get_countries()
#'
#' head(x, 10)



get_countries <- function() {

  html <- rvest::html_session(
    url = "https://www.protectedplanet.net/c/unep-regions"
  )

  countries <- rvest::html_table(html)

  countries <- sort(unlist(lapply(countries, function(x) x[ , 1])))

  return(countries)
}
