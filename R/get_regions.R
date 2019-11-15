#' @title Get World regions names
#'
#' @description Get World regions names from the Protected Planet website (based on the UNEP classification).
#'
#' @return A vector of World regions names.
#'
#' @details A Internet connexion is required.
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @seealso \link{\code{get_isocodes()}}, \link{\code{get_countries()}}, \link{\code{get_shapefile()}}
#'
#' @importFrom rvest html_session html_nodes html_text
#'
#' @export
#'
#' @examples
#' get_regions()



get_regions <- function() {

  html <- rvest::html_session(
    url = "https://www.protectedplanet.net/c/unep-regions"
  )

  regions <- rvest::html_nodes(html, ".region-link")
  regions <- rvest::html_text(regions)

  return(regions)
}
