#' Download Protected Areas by Country
#'
#' This function downloads protected areas for one country using the WDPA API.
#'
#' @param isocode a character specifying the ISO-3 code of the country
#' @param path the path (directory) to save spatial dataset (`.gpkg`). Default 
#' is: `wdpa/`.
#' @inheritParams get_token
#'
#' @return A `sf` object (**GEOMETRY**) of protected areas defined in the
#'   EPSG 4326 with the following 19 attributes: 
#' \describe{
#'   \item{wdpa_id}{the ID of the protected area on the WDPA database}
#'   \item{pa_name}{the name of the protected area on the WDPA database}
#'   \item{original_name}{the original name of the protected area}
#'   \item{country_iso3}{the ISO-3 code of the country}
#'   \item{country}{the name of the country}
#'   \item{owner_type}{the owner of the protected area}
#'   \item{is_marine}{a boolean: `TRUE` for marine and `FALSE` for terrestrial
#'   protected area}
#'   \item{designation}{the designation of the protected area}
#'   \item{iucn_category}{the IUCN category}
#'   \item{no_take_status}{the no take status}
#'   \item{reported_area}{the (reported) area of the protected area}
#'   \item{reported_marine_area}{the (reported) area of the marine part of the 
#'   protected area}
#'   \item{no_take_area}{the (reported) area of the no take part of the 
#'   protected area}
#'   \item{legal_status}{the legal status of the protected area}
#'   \item{management_authority}{the management authority}
#'   \item{governance}{the type of gouvernance}
#'   \item{management_plan}{the URL of the management plan}
#'   \item{protected_planet}{the URL of the protected area page on the Protected
#'   Planet website}
#'   \item{legal_status_updated}{the date of the last update of the legal status}
#' }
#'   
#' Spatial data are also written on the hard drive in the folder `path` as a 
#' **geopackage**. Filename is structured as **XXX_protectedareas.gpkg** (where 
#' `XXX` is the ISO-3 code of the country). If the `path` folder does not exist 
#' it will created relatively to the current directory.
#' 
#' @note Note that some geometries are **POINTS** not **(MULTIPOLYGONS)**.
#'
#' @seealso `wdpa_countries`, `get_countries`
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ## Get the ISO-3 code of Georgia ----
#' data("wdpa_countries", package = "worldpa")
#' wdpa_countries[grep("Georgia", wdpa_countries$"country_name"), 3:4]
#'
#' ##                                     country_name country_iso3
#' ## 133                                      Georgia          GEO
#' ## 235 South Georgia and the South Sandwich Islands          SGS
#'
#' ## Download Protected Areas for Georgia ----
#' worldpa::get_wdpa(isocode = "GEO", path = file.path("data", "wdpa"))
#' }



get_wdpa <- function(isocode, path = "wdpa", key = "WDPA_KEY") {


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


  ## Is ISO-3 code valid? ----

  response <- httr::GET(wdpa_fullurl("v3/countries/", isocode, "?token=", 
                                     wdpa_token))

  if (response$"status" == 404) {
    stop("Invalid ISO-3 code.\n",
         "Type `data(wdpa_countries)` or `wdpa_countries` to search for ",
         "ISO-3 codes.")
  }
  
  httr::stop_for_status(response)


  ## Get Total Number of Pages ----

  response <- httr::content(response, as = "text")
  response <- jsonlite::fromJSON(response)

  pas_count <- response$"country"$"pas_count"
  pages     <- seq_len(ceiling(pas_count / 50))

  
  ## Download Data ----
  
  if (pas_count) {

    for (page in pages) {

      request <- wdpa_fullurl("v3/protected_areas/search/?token=", wdpa_token,
                              "&with_geometry=true", "&country=", isocode,
                              "&per_page=50", "&page=", page)

      response <- httr::GET(request)
      response <- httr::content(response, as = "text")
      response <- jsonlite::fromJSON(response)
      response <- response$"protected_areas"

      pa_json  <- jsonlite::toJSON(response$"geojson"$"geometry")
      pa_sf    <- geojsonsf::geojson_sf(pa_json)

      attributs <- data.frame(
        wdpa_id              = response$"id",
        pa_name              = response$"name",
        original_name        = response$"original_name",
        country_iso3         = isocode,
        country              = unlist(lapply(response$"countries", 
                                             function(x) paste0(x[["name"]], 
                                                                collapse = "; "))),
        owner_type           = response$"owner_type",
        is_marine            = response$"marine",
        designation          = response$"designation"$"name",
        iucn_category        = response$"iucn_category"$"name",
        no_take_status       = response$"no_take_status"$"name",
        reported_area        = as.numeric(response$"reported_area"),
        reported_marine_area = as.numeric(response$"reported_marine_area"),
        no_take_area         = as.numeric(response$"no_take_status"$"area"),
        legal_status         = response$"legal_status"$"name",
        management_authority = response$"management_authority"$"name",
        governance           = response$"governance"$"governance_type",
        management_plan      = response$"management_plan",
        protected_planet     = response$"links"$"protected_planet",
        legal_status_updated = response$"legal_status_updated_at"
      )

      pa_sf <- sf::st_sf(attributs, geom = sf::st_geometry(pa_sf))

      if (page == 1) {

        all_pa <- pa_sf

      } else {

        all_pa <- rbind(all_pa, pa_sf)
      }
    }

    
    ## Write Layer ----
    
    if (!dir.exists(path)) dir.create(path, recursive = TRUE)
    
    sf::st_write(
      obj    = all_pa,
      dsn    = file.path(path, paste0(isocode, "_protectedareas.gpkg")),
      layer  = paste0(isocode, "_protectedareas"))

    return(all_pa)

  } else {

    stop("The WDPA database does not contain any protected areas for ", isocode)
  }
}
