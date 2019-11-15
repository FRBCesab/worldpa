get_isocodes <- function() {

  html <- rvest::html_session(
    url = "https://www.protectedplanet.net/c/unep-regions"
  )

  regions <- rvest::html_nodes(html, ".region-link")
  regions <- rvest::html_text(regions)

  countries <- rvest::html_table(html)
  names(countries) <- regions

  countries <- lapply(
    regions,
    function(x, countries) {
      countries[[x]] <- data.frame(region = x, countries[[x]])
    },
    countries
  )

  countries <- as.data.frame(do.call(rbind, countries))
  colnames(countries) <- c("region", "country", "iso3")

  return(countries)
}
