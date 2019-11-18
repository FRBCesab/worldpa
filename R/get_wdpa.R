#' @title Download World Protected Areas Shapefile
#'
#' @description Download World protected areas shapefiles from the Protected Planet website.
#'
#' @param regions [string] A vector of world regions (see \code{get_regions()} for the correct spelling).
#' @param countries [string] A vector of world countries (see \code{get_countries()} for the correct spelling).
#' @param path [string] The path (directory) to write downloaded files.
#'
#' @return Nothing.
#'
#' @details A Internet connexion is required.
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @importFrom utils download.file unzip
#'
#' @export
#'
#' @examples
#' # vignette(topic = "worldpa")



get_wdpa <- function(regions, countries, path = ".") {


  ## Checks   ----------

  if (!missing(regions) && !missing(countries)) {
    stop("Choose regions OR countries.")
  }

  if (!missing(regions)) {
    if (!all(regions %in% get_regions())) {
      stop("Unable to retrieve some regions. Please use `get_regions()` to get the correct spelling.")
    }
  }

  if (!missing(countries)) {
    if (!all(countries %in% get_countries())) {
      stop("Unable to retrieve some countries. Please use `get_countries()` to get the correct spelling.")
    }
  }


  ## Set Locale to English   ----------

  olocale <- Sys.getlocale("LC_TIME")

  if (.Platform$"OS.type" == "unix") {

    tmp <- Sys.setlocale("LC_TIME", "en_US.UTF-8")
  }

  if (.Platform$"OS.type" == "windows") {

    tmp <- Sys.setlocale("LC_TIME", "English")
  }


  ## Get Current Month and Year   ----------

  year  <- format(Sys.time(), "%Y")
  month <- format(Sys.time(), "%b")
  substr(month, 1, 1) <- toupper(substr(month, 1, 1))


  ## Reset Locale   ----------

  tmp <- Sys.setlocale("LC_TIME", olocale)


  ## Protected Planet Base URL   ----------

  base_url <- paste0(
    "https://www.protectedplanet.net/",
    "downloads/"
  )


  ## Download World Protected Areas Dataset   ----------

  if (missing(regions) && missing(countries)) {

    filename <- paste0("WDPA_", month, year)
    url      <- paste0(base_url, filename, "?type=shapefile", collapse = "")

    download.file(url, file.path(path, paste0(filename, "_WORLD.zip")))


  ## Download Protected Areas Dataset by Country   ----------

  } else {

    infos <- get_isocodes()

    if (!missing(regions)) {

      iso3 <- infos[infos[ , "region"] %in% regions, "iso3"]
    }

    if (!missing(countries)) {

      iso3 <- infos[infos[ , "country"] %in% countries, "iso3"]
    }

    for (iso in iso3) {

      filename <- paste0("WDPA_", month, year, "_", iso)
      url      <- paste0(base_url, filename, "?type=shapefile", collapse = "")

      attempt <- tryCatch({
        download.file(
          url      = url,
          destfile = file.path(path, paste0(filename, ".zip"))
        )},
        error = function(e){}
      )

      if (!is.null(attempt)) {

        unzip(
          zipfile  = file.path(path, paste0(filename, ".zip")),
          exdir    = path
        )

        rms <- file.remove(file.path(path, paste0(filename, ".zip")))

        fls <- list.files(
          path      = path,
          pattern   = "shapefile-points",
          full.name = TRUE
        )

        rms <- file.remove(fls)
      }
    }
  }
}
