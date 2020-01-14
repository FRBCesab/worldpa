#' @title Check Protected Planet API token
#'
#' @description This function checks if the user has stored a valid Protected Planet API token in the R environment (.Renviron) file under the key \code{WDPA_KEY}.
#'
#' @param key The name of the token value stored in the .Renviron file (recommended key name: \code{WDPA_KEY}).
#'
#' @return A vector of length one with the value of the API token.
#'
#' @details Before using this package for the first time, the user must follow these steps:
#' \itemize{
#'   \item Fill in the form available at: \url{https://api.protectedplanet.net/request} to obtain a personal API token;
#'   \item Store the token in the .Renviron file under the key \code{WDPA_KEY}. User can use the function \code{usethis::edit_r_environ()}.
#' }
#'
#' @importFrom httr GET
#'
#' @export
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @examples
#' ## get_token()

get_token <- function(key = "WDPA_KEY") {

  wdpa_key <- Sys.getenv(key)

  if (wdpa_key == "") {

    stop(
      paste0(
        "Missing WDPA API token. Please ensure:\n",
        "  1) You completed this form [https://api.protectedplanet.net/request] to get the token,\n",
        "  2) You stored the value in the .Renviron with the name WDPA_KEY."
      )
    )
  }

  response <- httr::GET(paste0("https://api.protectedplanet.net/test?token=", wdpa_key))

  if (response$status == 401) {

    stop(
      paste0(
        "Invalid WDPA API token. Please ensure:\n",
        "  1) You completed this form [https://api.protectedplanet.net/request] to get the token,\n",
        "  2) You stored the value in the .Renviron with the name WDPA_KEY."
      )
    )
  }

  if (response$status != 200) {

    stop("Something go wrong with your API token.")
  }

  return(wdpa_key)
}
