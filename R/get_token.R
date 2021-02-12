#' Check Protected Planet API Token
#'
#' This function checks if the user has stored a valid Protected Planet API
#'   token in the R environment file (`.Renviron`) under the key `WDPA_KEY`.
#'
#' @param key a character providing the WDPA token value stored in the
#'   `.Renviron` file (recommended key name: `WDPA_KEY`).
#'
#' @return A vector of length one with the value of the API token.
#'
#' @details Before using this package for the first time, the user must follow
#'   these steps:
#' \itemize{
#'   \item Fill in the form available at:
#'         \url{https://api.protectedplanet.net/request} to obtain a personal
#'         API token;
#'   \item Store the token in the `.Renviron` file under the key `WDPA_KEY`.
#'         User can use the function \link{\code{usethis::edit_r_environ}} to
#'         to open this file.
#' }
#'
#' @export
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @examples
#' \dontrun{
#' ## Check if Protected Planet API token is stored ----
#' worldpa::get_token()
#' }



get_token <- function(key = "WDPA_KEY") {

  wdpa_token <- Sys.getenv(key)

  if (wdpa_token == "") {
    stop("Missing WDPA API Token.\n",
         "Please make sure you:\n",
         " 1. have completed this form ",
         "<https://api.protectedplanet.net/request> ",
         "to get your own token, and\n",
         " 2. have stored the value in the `.Renviron` file with the name ",
         "WDPA_KEY.")
  }

  response <- httr::GET(wdpa_fullurl("test?token=", wdpa_token))

  if (response$"status" == 401) {
    stop("Invalid WDPA API Token.\n",
         "Please make sure you:\n",
         " 1. have completed this form ",
         "<https://api.protectedplanet.net/request> ",
         "to get your own token, and\n",
         " 2. have stored the value in the `.Renviron` file with the name ",
         "WDPA_KEY.")
  }

  httr::stop_for_status(response)

  return(wdpa_token)
}
