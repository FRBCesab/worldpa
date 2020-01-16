#' @title Download Protected Areas by Country
#'
#' @description This function downloads protected areas for one country using the WDPA API.
#'
#' @param isocode The ISO-3 code of the country.
#'
#' @return A MULTIPOLYGON Simple feature of protected areas defined in the EPSG 4326. The shapefile is also written on the hard drive (in the current directory).
#'
#' @importFrom jsonlite fromJSON
#' @importFrom geojsonsf geojson_sf
#' @importFrom sf st_sf st_collection_extract st_cast st_write st_geometry
#'
#' @export
#'
#' @author Nicolas CASAJUS, \email{nicolas.casajus@@fondationbiodiversite.fr}
#'
#' @examples
#' ## Get Protected Areas for Georgia
#'
#' ## data(wdpa_countries)
#'
#' ## wdpa_countries[grep("Geor", wdpa_countries[ , "country_name"]), ]
#' ##     region_name region_iso2                                 country_name country_iso3 pas_count
#' ## 133      Europe          EU                                      Georgia          GEO        89
#' ## 235       Polar          PO South Georgia and the South Sandwich Islands          SGS         1
#'
#' ## get_wdpa(isocode = "GEO")
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

  response <- GET(request)

  if (response$status == 404) {

    stop("Invalid ISO-3 code. Type `data(wdpa_countries)` and `wdpa_countries` to search ISO-3 code.")

  }

  response <- httr::content(response, as = "text")
  response <- fromJSON(response)

  pas_count <- response$country$pas_count
  pages     <- seq_len(ceiling(pas_count / 50))

  if (pas_count) {

    base_url      <- "https://api.protectedplanet.net/"
    category      <- "v3/protected_areas/search/"
    wdpa_token    <- Sys.getenv("WDPA_KEY")
    with_geometry <- "true"


    for (page in pages) {

      request <- paste0(
        base_url,
        category,
        "?token=", wdpa_token,
        "&with_geometry=", "true",
        "&country=", isocode,
        "&per_page=", 50,
        "&page=", page
      )

      response <- GET(request)
      response <- httr::content(response, as = "text")
      response <- fromJSON(response)
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

      pa_sf <- st_sf(attributs, geom = st_geometry(pa_sf))
      pa_sf <- st_collection_extract(pa_sf, type = "POLYGON")
      pa_sf <- st_cast(pa_sf, "MULTIPOLYGON")

      if (page == 1) {

        all_pa <- pa_sf

      } else {

        all_pa <- rbind(all_pa, pa_sf)
      }
    }

    dir.create(paste0(isocode, "_protectedareas"), showWarnings = FALSE)
    st_write(all_pa, dsn = paste0(isocode, "_protectedareas"), 
      layer = paste0(isocode, "_protectedareas"), driver = "ESRI Shapefile", 
      quiet = TRUE)

    return(all_pa)

  } else {

    cat("The WDPA does not contain any protected areas for", isocode)
  }
}
