get_countries <- function(update = FALSE, sleep = 0) {

  if (!update) {

    return(data(wdpa_countries))

  } else {

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
        response <- response$countries

        if (length(response) > 0) {

          response <- data.frame(
            region_name  = response$region$name,
            region_iso2  = response$region$iso,
            country_name = response$name,
            country_iso3 = response$iso_3,
            pas_count    = response$pas_count,
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

    wdpa_countries <- wdpa_countries[with(wdpa_countries, order(region_name, country_name)), ]
    rownames(wdpa_countries) <- NULL

    return(wdpa_countries)

  }
}
