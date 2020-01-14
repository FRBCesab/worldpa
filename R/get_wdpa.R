get_wdpa <- function(isocode) {


  if (missing(isocode)) {

    stop("Please provide one country ISO-3 code. Type `data(wdpa_countries)` and `wdpa_countries` to search ISO-3 code.")

  }

  if (length(isocode) > 1) {

    stop("This function works on only one single ISO-3 code.")

  }

  base_url   <- "https://api.protectedplanet.net/"
  category   <- "v3/countries/"
  wdpa_token <- get_token()

  request <- paste0(
    base_url,
    category,
    isocode,
    "?token=", wdpa_token
  )

  response <- httr::GET(request)

  if (response$status == 404) {

    stop("Invalid ISO-3 code. Type `data(wdpa_countries)` and `wdpa_countries` to search ISO-3 code.")

  }

  response <- httr::content(response, as = "text")
  response <- jsonlite::fromJSON(response)

  pas_count <- response$country$pas_count
  pages     <- 1:ceiling(pas_count / 50)



  base_url      <- "https://api.protectedplanet.net/"
  category      <- "v3/protected_areas/search/"
  wdpa_token    <- Sys.getenv("WDPA_KEY")
  with_geometry <- "true"


  for (page in pages) {

    cat("Page", page, "on", max(pages), "\r")

    request <- paste0(
      base_url,
      category,
      "?token=", wdpa_token,
      "&with_geometry=", "true",
      "&country=", isocode,
      "&per_page=", 50,
      "&page=", page
    )

    response <- httr::GET(request)
    response <- httr::content(response, as = "text")
    response <- jsonlite::fromJSON(response)
    response <- response$protected_areas

    pa_json  <- jsonlite::toJSON(response$geojson$geometry)
    pa_sf    <- geojsonsf::geojson_sf(pa_json)

    attributs <- data.frame(
      wdpa_id       = response$wdpa_id,
      pa_name       = response$name,
      country_iso3  = isocode,
      is_marine     = response$marine,
      designation   = response$designation$name,
      iucn_category = response$iucn_category$name
    )

    pa_sf <- sf::st_sf(attributs, geom = sf::st_geometry(pa_sf))
    pa_sf <- sf::st_collection_extract(pa_sf, type = "POLYGON")
    pa_sf <- sf::st_cast(pa_sf, "MULTIPOLYGON")

    if (page == 1) {

      all_pa <- pa_sf

    } else {

      all_pa <- rbind(all_pa, pa_sf)
    }
  }

  dir.create(paste0(isocode, "_protectedareas"), showWarnings = FALSE)
  sf::st_write(all_pa, dsn = paste0(isocode, "_protectedareas"), layer = paste0(isocode, "_protectedareas"), driver = "ESRI Shapefile")

  return(all_pa)

}
