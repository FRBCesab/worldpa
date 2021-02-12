#' Get World Countries Listed by the UNEP-WCMC
#'
#' This function gets the list of world countries listed by the UNEP-WCMC using
#'   the Protected Planet API \url{https://api.protectedplanet.net/}.
#'
#' @param sleep a numeric specifying the time interval (in seconds) to suspend
#'   between each API request.
#'
#' @return A data frame with the following informations (columns) for each
#' World countries (rows):
#' \describe{
#'   \item{region_name}{the name of the region}
#'   \item{region_iso2}{the ISO-2 code of the region}
#'   \item{country_name}{the name of the country}
#'   \item{country_iso3}{the ISO-3 code of the country}
#'   \item{pas_count}{the number of protected areas per country}
#' }
#'
#' @seealso `wdpa_countries`, `get_wdpa`
#'
#' @export
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @examples
#' \dontrun{
#' ## List World Countries ----
#' countries <- worldpa::get_countries(sleep = 0.25)
#' head(countries)
#'
#' ##   region_name region_iso2 country_name country_iso3 pas_count
#' ## 1      Africa          AF      Algeria          DZA        78
#' ## 2      Africa          AF       Angola          AGO        14
#' ## 3      Africa          AF        Benin          BEN        64
#' ## 4      Africa          AF     Botswana          BWA        22
#' ## 5      Africa          AF Burkina Faso          BFA       112
#' ## 6      Africa          AF      Burundi          BDI        21
#' }



get_countries <- function(sleep = 0) {

  wdpa_token <- get_token()

  base_url   <- "https://api.protectedplanet.net/"
  category   <- "v3/countries"
  per_page   <- 50

  wdpa_countries  <- data.frame()

  page    <- 1
  content <- TRUE

  while (content) {

    request <- paste0(
      base_url,
      category,
      "?token=", wdpa_token,
      "&per_page=", per_page,
      "&page=", page
    )

    response <- httr::GET(request)

    if (response$status == 200) {

      response <- httr::content(response, as = "text")
      response <- jsonlite::fromJSON(response)
      response <- response$"countries"

      if (length(response)) {

        response <- data.frame(
          region_name  = response$"region"$"name",
          region_iso2  = response$"region"$"iso",
          country_name = response$"name",
          country_iso3 = response$"iso_3",
          pas_count    = response$"pas_count",
          stringsAsFactors = FALSE
        )

        wdpa_countries <- rbind(wdpa_countries, response)

        page <- page + 1

      } else {

        content <- FALSE

      }

    } else {

      stop("Bad request.")

    }

    Sys.sleep(sleep)
  }

  wdpa_countries <- wdpa_countries[with(wdpa_countries, order(region_name,
    country_name)), ]
  rownames(wdpa_countries) <- NULL

  return(wdpa_countries)
}
