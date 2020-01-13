#' @title {{ ... }}
#'
#' @description {{ ... }}
#'
#' @param key [string] {{ ... }}
#'
#' @return {{ ... }}
#'
#' @details {{ ... }}
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}


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

    stop("Something went wrong with your API token.")
  }

  return(wdpa_key)
}
