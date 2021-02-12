#' Helpers Functions
#'
#' `wdpa_baseurl()`: Set the base URL of the WDPA API
#' `wdpa_fullurl()`: Add parameters to the base URL of the WDPA API
#'
#' @noRd

wdpa_baseurl <- function() "https://api.protectedplanet.net/"

wdpa_fullurl <- function(...) paste0(wdpa_baseurl(), ...)
