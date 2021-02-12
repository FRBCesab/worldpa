#' Download Protected Areas by Country
#'
#' This function downloads protected areas for one country using the WDPA API.
#'
#' @param isocode a character specifying the ISO-3 code of the country.
#' @param key a character providing the WDPA token value stored in the
#'   `.Renviron` file (recommended key name: `WDPA_KEY`).
#'
#' @return A `MULTIPOLYGON` Simple feature of protected areas defined in the
#'   EPSG 4326. The shapefile is also written on the hard drive
#'   (in the current directory).
#'
#' @export
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @examples
#' \dontrun{
#' ## Get the ISO-3 code of Georgia ----
#' data("wdpa_countries", package = "worldpa")
#' wdpa_countries[grep("Geor", wdpa_countries$"country_name"), 3:4]
#'
#' ##                                     country_name country_iso3
#' ## 133                                      Georgia          GEO
#' ## 235 South Georgia and the South Sandwich Islands          SGS
#'
#' ## Download Protected Areas for Georgia ----
#' worldpa::get_wdpa(isocode = "GEO")
#'
#' ## Simple feature collection with 89 features and 6 fields
#' ## geometry type:  MULTIPOLYGON
#' ## dimension:      XY
#' ## bbox:           xmin: 40.31 ymin: 41.093 xmax: 46.736 ymax: 43.544
#' ## epsg (SRID):    4326
#' ## proj4string:    +proj=longlat +datum=WGS84 +no_defs
#' ## First 10 features:
#' ##    wdpa_id           pa_name country_iso3 is_marine           designation iucn_category
#' ## 1     1652           Borjomi          GEO     FALSE Strict Nature Reserve            Ia
#' ## 2     1653         Lagodekhi          GEO     FALSE Strict Nature Reserve            Ia
#' ## 3     1654             Ritsa          GEO     FALSE Strict Nature Reserve            Ia
#' ## 4     1656         Kintrishi          GEO     FALSE Strict Nature Reserve            Ia
#' ## 5     1657           Liakhvi          GEO     FALSE Strict Nature Reserve            Ia
#' ## 6     1660        Vashlovani          GEO     FALSE Strict Nature Reserve            Ia
#' ## 7     1664 Bichvinta-Miusera          GEO     FALSE Strict Nature Reserve            Ia
#' ## 8     1665       Mariamjvari          GEO     FALSE Strict Nature Reserve            Ia
#' ## 9     1666          Kolkheti          GEO      TRUE         National Park            II
#' ## 10    1667          Sataplia          GEO     FALSE Strict Nature Reserve            Ia
#' }



get_wdpa <- function(isocode, key = "WDPA_KEY") {


  ## Checks inputs ----

  if (missing(isocode)) {
    stop("Please provide one country ISO-3 code.\n",
         "Type `data(wdpa_countries)` or `wdpa_countries` to search for ",
         "ISO-3 codes.")
  }

  if (length(isocode) > 1) {
    stop("This function only works with one ISO-3 code.")
  }

  wdpa_token <- get_token(key)


  ## Is ISO-3 code valid?

  response <- httr::GET(wdpa_fullurl("v3/countries/?token=", wdpa_token))

  if (response$status == 404) {
    stop("Invalid ISO-3 code.\n",
         "Type `data(wdpa_countries)` or `wdpa_countries` to search for ",
         "ISO-3 codes.")
  }


  ## Get Total Number of Pages ----

  response <- httr::content(response, as = "text")
  response <- jsonlite::fromJSON(response)

  pas_count <- response$"country"$"pas_count"
  pages     <- seq_len(ceiling(pas_count / 50))

  if (pas_count) {

    for (page in pages) {

      request <- wdpa_fullurl("v3/protected_areas/search/?token=", wdpa_token,
                              "&with_geometry=true", "&country=", isocode,
                              "&per_page=50", "&page=", page)

      response <- httr::GET(request)
      response <- httr::content(response, as = "text")
      response <- jsonlite::fromJSON(response)
      response <- response$"countries"

      pa_json  <- jsonlite::toJSON(response$"geojson"$"geometry")
      pa_sf    <- geojsonsf::geojson_sf(pa_json)

      attributs <- data.frame(
        wdpa_id       = response$"id",
        pa_name       = response$"name",
        country_iso3  = isocode,
        is_marine     = response$"marine",
        designation   = response$"designation"$"name",
        iucn_category = response$"iucn_category"$"name"
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

    sf::st_write(
      obj    = all_pa,
      dsn    = paste0(isocode, "_protectedareas"),
      layer  = paste0(isocode, "_protectedareas"),
      driver = "ESRI Shapefile",
      quiet  = TRUE)

    return(all_pa)

  } else {

    stop("The WDPA database does not contain any protected areas for ", isocode)
  }
}
