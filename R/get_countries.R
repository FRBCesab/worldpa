get_countries <- function() {

  html <- rvest::html_session(
    url = "https://www.protectedplanet.net/c/unep-regions"
  )

  countries <- rvest::html_table(html)

  countries <- sort(unlist(lapply(countries, function(x) x[ , 1])))

  return(countries)
}
