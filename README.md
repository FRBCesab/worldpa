worldpa <img src="inst/img/worldpa-sticker.png" height="120" align="right"/>
=========================================================

[![Build Status](https://travis-ci.org/FRBCesab/worldpa.svg?branch=master)](https://travis-ci.org/FRBCesab/worldpa)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/FRBCesab/worldpa?branch=master&svg=true)](https://ci.appveyor.com/project/FRBCesab/worldpa) [![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![License GPL-3](https://img.shields.io/badge/licence-GPLv3-8f10cb.svg)](http://www.gnu.org/licenses/gpl.html)
[![DOI](https://zenodo.org/badge/221718108.svg)](https://zenodo.org/badge/latestdoi/221718108)


Overview
--------

The R package is an interface of the World Database on Protected Areas (WDPA) hosted in the Protected planet website: [https://www.protectedplanet.net](https://www.protectedplanet.net). The main function, `get_wdpa()` downloads spatial shapefile of protected areas at three different levels: country, region or the world.



Terms and conditions
--------

You must ensure that the following citation is always clearly reproduced in any publication or analysis involving the Protected Planet Materials in any derived form or format:

> UNEP-WCMC and IUCN (`YEAR`) Protected Planet: The World Database on Protected Areas (WDPA). Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net (dataset downloaded the `YEAR/MONTH`).

For further details on terms and conditions of the WDPA usage, please visit the page: [https://www.protectedplanet.net/c/terms-and-conditions](https://www.protectedplanet.net/c/terms-and-conditions).



Installation
--------

First install the package [`devtools`](http://cran.r-project.org/web/packages/devtools/index.html) from the CRAN.

```r
install.packages("devtools", dependencies = TRUE)
```

Then install the `worldpa` package from GitHub.

```r
devtools::install_github("frbcesab/worldpa", build_vignettes = TRUE)
```



Getting started
--------

Load the package `worldpa` in the R memory.

```r
library(worldpa)
```

And browse the vignette to get started.

```r
vignette(topic = "worldpa")
```

Functions documentation can be found at: [https://frbcesab.github.io/worldpa/reference/index.html](https://frbcesab.github.io/worldpa/reference/index.html)
