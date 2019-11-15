get_regions <- function() {

  html <- rvest::html_session(
    url = "https://www.protectedplanet.net/c/unep-regions"
  )

  regions <- rvest::html_nodes(html, ".region-link")
  regions <- rvest::html_text(regions)

  return(regions)
}
